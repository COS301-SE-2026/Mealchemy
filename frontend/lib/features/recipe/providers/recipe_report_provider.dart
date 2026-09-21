import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../../../core/providers/api_service_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../repositories/recipe_report_repository.dart';

typedef RecipeReportSession = ({
  int? userId,
  String? token,
  bool restoring,
  bool hasValidCredential,
});

final recipeReportSessionProvider = Provider<RecipeReportSession>((ref) {
  return ref.watch(
    authProvider.select(
      (state) => (
        userId: state.userId,
        token: state.token,
        restoring: state.isRestoring,
        hasValidCredential: state.isLoggedIn && state.hasValidCredential,
      ),
    ),
  );
});

final recipeReportRepositoryProvider = Provider<RecipeReportRepository>((ref) {
  return ApiRecipeReportRepository(ref.watch(dioProvider));
});

final recipeReportUnavailableMessageProvider = Provider<String?>((ref) {
  final session = ref.watch(recipeReportSessionProvider);

  if (session.restoring) {
    return 'Checking your session…';
  }

  if (session.userId == null ||
      session.token == null ||
      !session.hasValidCredential) {
    return 'Please sign in again before reporting a recipe.';
  }

  switch (ref.watch(networkStatusProvider)) {
    case NetworkStatus.checking:
      return 'Checking your connection…';
    case NetworkStatus.offline:
      return 'Connect to the internet to report this recipe.';
    case NetworkStatus.online:
      return null;
  }
});

final recipeReportReasonsProvider =
    FutureProvider.autoDispose<List<RecipeReportReason>>((ref) async {
  ref.watch(recipeReportSessionProvider);

  final unavailable = ref.watch(recipeReportUnavailableMessageProvider);
  if (unavailable != null) {
    throw StateError(unavailable);
  }

  return ref.watch(recipeReportRepositoryProvider).getReasons();
});

class RecipeReportState {
  const RecipeReportState({
    this.isSubmitting = false,
    this.isComplete = false,
    this.message,
  });

  final bool isSubmitting;
  final bool isComplete;
  final String? message;
}

class RecipeReportNotifier extends StateNotifier<RecipeReportState> {
  RecipeReportNotifier(this._ref, this._recipeId, this._keepAlive)
      : super(const RecipeReportState());

  final Ref _ref;
  final int _recipeId;
  final void Function() Function() _keepAlive;

  Future<void> submit({
    required String reasonValue,
    required RecipeReportSession confirmedSession,
  }) async {
    if (state.isSubmitting || state.isComplete) return;

    if (_ref.read(recipeReportSessionProvider) != confirmedSession) {
      state = const RecipeReportState(
        message: 'Your session changed. Close this window and try again.',
      );
      return;
    }

    final unavailable = _ref.read(recipeReportUnavailableMessageProvider);
    if (unavailable != null) {
      state = RecipeReportState(message: unavailable);
      return;
    }

    final reasonsState = _ref.read(recipeReportReasonsProvider);
    final reasons = reasonsState.valueOrNull;

    if (reasonsState.isLoading ||
        reasonsState.hasError ||
        reasons == null ||
        !reasons.any((reason) => reason.value == reasonValue)) {
      state = const RecipeReportState(
        message: 'Please select an available report reason.',
      );
      return;
    }

    final repository = _ref.read(recipeReportRepositoryProvider);
    final release = _keepAlive();

    state = const RecipeReportState(isSubmitting: true);

    try {
      await repository.reportRecipe(
        recipeId: _recipeId,
        reasonValue: reasonValue,
      );

      if (!mounted ||
          _ref.read(recipeReportSessionProvider) != confirmedSession) {
        return;
      }

      state = const RecipeReportState(
        isComplete: true,
        message: 'Report submitted. Thank you for helping our community.',
      );
    } catch (error) {
      if (!mounted ||
          _ref.read(recipeReportSessionProvider) != confirmedSession) {
        return;
      }

      if (error is DioException && error.response?.statusCode == 409) {
        state = const RecipeReportState(
          isComplete: true,
          message: 'You already have a pending report for this recipe.',
        );
      } else {
        state = RecipeReportState(
          message: recipeReportErrorMessage(error, submitting: true),
        );
      }
    } finally {
      release();
    }
  }
}

final recipeReportProvider = StateNotifierProvider.autoDispose
    .family<RecipeReportNotifier, RecipeReportState, int>((ref, recipeId) {
  //changing accounts or credentials replaces old operation state
  ref.watch(recipeReportSessionProvider);

  return RecipeReportNotifier(
    ref,
    recipeId,
    () {
      final link = ref.keepAlive();
      return link.close;
    },
  );
});

String recipeReportErrorMessage(
  Object error, {
  bool submitting = false,
}) {
  if (error is DioException) {
    switch (error.response?.statusCode) {
      case 400:
        return 'That reason is no longer available. Close this window '
            'and select a reason again.';
      case 401:
        return 'Please sign in again before reporting a recipe.';
      case 403:
        return 'You do not have permission to report this recipe.';
      case 404:
        return 'This recipe is no longer available in the community.';
    }

    if (submitting) {
      return 'We could not confirm whether your report was received. '
          'You can try again; duplicate pending reports are prevented.';
    }
  }

  return submitting
      ? 'Unable to submit your report. Please try again.'
      : 'Unable to load report reasons. Please try again.';
}
