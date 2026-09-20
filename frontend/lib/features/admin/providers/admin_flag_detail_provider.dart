import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../recipe/models/recipe_ingredient.dart';
import '../../recipe/models/recipe_step.dart';
import '../../recipe/providers/recipe_provider.dart';
import '../models/admin_models.dart';
import 'admin_access_provider.dart';

class AdminDetailAccessException implements Exception {
  const AdminDetailAccessException(this.access);

  final AdminAccess access;
}

class AdminFlagReview {
  const AdminFlagReview({
    required this.detail,
    required this.ingredients,
    required this.steps,
  });

  final FlaggedRecipeDetail detail;
  final AsyncValue<List<RecipeIngredient>> ingredients;
  final AsyncValue<List<RecipeStep>> steps;
}

//authentication/permission failures must hide the whole review
//other ingredient/step failures can be displayed within their own section
void _checkAccessError(Object error) {
  if (error is! DioException) return;

  if (error.response?.statusCode == 401) {
    throw const AdminDetailAccessException(AdminAccess.signInRequired);
  }

  if (error.response?.statusCode == 403) {
    throw const AdminDetailAccessException(AdminAccess.forbidden);
  }
}

Future<AsyncValue<List<T>>> _loadSection<T>(
  Future<List<T>> Function() load,
) async {
  try {
    return AsyncData(await load());
  } catch (error, stackTrace) {
    _checkAccessError(error);
    return AsyncError(error, stackTrace);
  }
}

final adminFlagDetailProvider =
    FutureProvider.autoDispose.family<AdminFlagReview, int>(
  (ref, flaggedId) async {
    ref.watch(adminAccessContextProvider);

    final access = ref.watch(adminAccessStateProvider);
    if (access != AdminAccess.allowed) {
      throw AdminDetailAccessException(access);
    }

    if (flaggedId <= 0) {
      throw ArgumentError.value(flaggedId, 'flaggedId');
    }

    final adminRepository = ref.watch(adminRepositoryProvider);

    //use fresh server data for moderation, without offline cache fallback
    final recipeRepository = ref.watch(remoteRecipeRepositoryProvider);

    var disposed = false;
    ref.onDispose(() => disposed = true);

    try {
      final detail = await adminRepository.getFlagDetail(flaggedId);

      //don't start additional requests for obsolete session/page
      if (disposed) {
        throw StateError('This report request is no longer active.');
      }

      final recipeId = detail.recipe.recipeId;

      final sections = await Future.wait<Object>([
        _loadSection<RecipeIngredient>(() async {
          final ingredients =
              await recipeRepository.getRecipeIngredients(recipeId);
          return [...ingredients]
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        }),
        _loadSection<RecipeStep>(() async {
          final steps = await recipeRepository.getRecipeSteps(recipeId);
          return [...steps]..sort((a, b) => a.stepNr.compareTo(b.stepNr));
        }),
      ]);

      return AdminFlagReview(
        detail: detail,
        ingredients: sections[0] as AsyncValue<List<RecipeIngredient>>,
        steps: sections[1] as AsyncValue<List<RecipeStep>>,
      );
    } catch (error) {
      _checkAccessError(error);
      rethrow;
    }
  },
);

String adminDetailErrorMessage(Object error) {
  if (error is DioException) {
    if (error.response?.statusCode == 404) {
      return 'This report or its related content is no longer available.';
    }

    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      final message = (data['message'] as String).trim();
      if (message.isNotEmpty) return message;
    }

    if (error.response == null) {
      return 'Could not connect to load this report. Please try again.';
    }
  }

  return 'Could not load this report. Please try again.';
}
