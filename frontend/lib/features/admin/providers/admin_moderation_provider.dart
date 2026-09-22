import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../discovery/providers/discovery_provider.dart';
import '../../guided_discovery/providers/guided_discovery_provider.dart';
import '../../recipe/providers/recipe_provider.dart';
import '../../vault/providers/vault_provider.dart';
import '../models/admin_models.dart';
import 'admin_access_provider.dart';
import 'admin_flag_detail_provider.dart';
import 'admin_queue_provider.dart';

enum AdminModerationAction { dismiss, remove }

class AdminModerationState {
  const AdminModerationState({
    this.isSubmitting = false,
    this.completed = false,
    this.message,
    this.isError = false,
  });

  final bool isSubmitting;
  final bool completed;
  final String? message;
  final bool isError;
}

final adminModerationEnabledProvider = Provider.autoDispose<bool>((ref) {
  final context = ref.watch(adminAccessContextProvider);
  final access = ref.watch(adminAccessStateProvider);

  return access == AdminAccess.allowed &&
      context.userId != null &&
      context.token != null &&
      context.hasValidCredential &&
      !context.restoring &&
      context.network == NetworkStatus.online;
});

//kept separate so action tests can observe refreshes without starting unrelated feature repositories
final adminModerationRefreshProvider =
    Provider<void Function(int recipeId, bool removed)>((ref) {
  return (recipeId, removed) {
    //1 action can resolve several flags so refresh every queue/detail
    ref.invalidate(adminQueueProvider);
    ref.invalidate(adminFlagDetailProvider);

    if (!removed) return;

    ref.invalidate(recipesProvider);
    ref.invalidate(recipeByIdProvider(recipeId));
    ref.invalidate(recipeDetailProvider(recipeId));
    ref.invalidate(folderRecipesProvider);
    ref.invalidate(folderRecipeDisplayProvider);
    ref.invalidate(vaultSearchResultsProvider);
    ref.invalidate(guidedDiscoveryProvider);

    //notifiers load explicitly rather than in constructors
    ref.invalidate(discoveryProvider);
    ref.invalidate(dashboardProvider);

    unawaited(
      ref
          .read(discoveryProvider.notifier)
          .loadDiscovery()
          .catchError((Object _) {}),
    );
    unawaited(
      ref
          .read(dashboardProvider.notifier)
          .loadDashboard()
          .catchError((Object _) {}),
    );
  };
});

class AdminModerationNotifier extends StateNotifier<AdminModerationState> {
  AdminModerationNotifier(
    this._ref, {
    required void Function() Function() keepAlive,
  })  : _keepAlive = keepAlive,
        super(const AdminModerationState());

  final Ref _ref;
  final void Function() Function() _keepAlive;

  Future<void> submit({
    required FlaggedRecipe flag,
    required AdminModerationAction action,
    required AdminAccessContext confirmedSession,
  }) async {
    if (state.isSubmitting || state.completed) return;

    final currentSession = _ref.read(adminAccessContextProvider);

    //don't apply confirmation made under diff account/token
    if (currentSession.userId != confirmedSession.userId ||
        currentSession.token != confirmedSession.token ||
        !_ref.read(adminModerationEnabledProvider)) {
      state = const AdminModerationState(
        message: 'Your session or connection changed. Refresh the report.',
        isError: true,
      );
      return;
    }

    if (flag.status != FlagStatus.pending) {
      state = const AdminModerationState(
        message: 'This report has already been resolved. Refresh the report.',
        isError: true,
      );
      return;
    }

    final repository = _ref.read(adminRepositoryProvider);
    final refresh = _ref.read(adminModerationRefreshProvider);
    final release = _keepAlive();

    state = const AdminModerationState(isSubmitting: true);

    try {
      final result = action == AdminModerationAction.dismiss
          ? await repository.dismissFlag(flag.flaggedId)
          : await repository.removeFromCommunity(flag.flaggedId);

      if (!mounted) return;

      final latestSession = _ref.read(adminAccessContextProvider);
      if (latestSession.userId != confirmedSession.userId ||
          latestSession.token != confirmedSession.token) {
        return;
      }

      final expectedStatus = action == AdminModerationAction.dismiss
          ? FlagStatus.reviewed
          : FlagStatus.removed;

      final expectedResult =
          result.flaggedId == flag.flaggedId && result.status == expectedStatus;

      state = AdminModerationState(
        completed: true,
        isError: !expectedResult,
        message: expectedResult
            ? action == AdminModerationAction.dismiss
                ? 'Report dismissed. Pending reports for the same recipe '
                    'and reason were also resolved.'
                : 'Recipe removed from the community. The author keeps '
                    'their recipe in their private vault.'
            : 'The server returned an unexpected report status. '
                'Review the refreshed report before taking another action.',
      );

      //uccessful mutation must not be reported as failed because a subsequent refresh fails
      try {
        refresh(
          flag.recipeId,
          action == AdminModerationAction.remove,
        );
      } catch (_) {
        state = AdminModerationState(
          completed: true,
          message: '${state.message} Refresh the page to see current data.',
          isError: state.isError,
        );
      }
    } catch (error) {
      if (!mounted) return;

      state = AdminModerationState(
        message: _message(error),
        isError: true,
      );

      if (error is DioException &&
          (error.response?.statusCode == 401 ||
              error.response?.statusCode == 403)) {
        _ref.invalidate(adminAccessProvider);
      }
    } finally {
      release();
    }
  }

  String _message(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        final message = (data['message'] as String).trim();
        if (message.isNotEmpty) return message;
      }

      if (error.response == null) {
        return 'The action could not be confirmed. Refresh the report '
            'before trying again.';
      }
    }

    return 'Could not complete the action. Please try again.';
  }
}

final adminModerationProvider = StateNotifierProvider.autoDispose
    .family<AdminModerationNotifier, AdminModerationState, int>(
  (ref, flaggedId) {
    //reset operation state when the authenticated session changes
    //network changes alone must not reset in-flight submission
    ref.watch(
      adminAccessContextProvider.select(
        (context) => (
          context.userId,
          context.token,
          context.hasValidCredential,
          context.restoring,
        ),
      ),
    );

    return AdminModerationNotifier(
      ref,
      keepAlive: () {
        final link = ref.keepAlive();
        return link.close;
      },
    );
  },
);
