import 'package:dio/dio.dart';

import '../models/recipe_edit_lock.dart';
import 'recipe_lock_repository.dart';

class ApiRecipeLockRepository implements RecipeLockRepository {
  ApiRecipeLockRepository(this._dio);

  final Dio _dio;

  @override
  Future<RecipeEditLock?> getLock(int recipeId) async {
    _validateRecipeId(recipeId);

    final response = await _dio.get<dynamic>(
      '/recipes/$recipeId/lock',
    );

    if (response.statusCode == 204) return null;

    return _parseLock(response, recipeId);
  }

  @override
  Future<RecipeEditLock> acquireLock(int recipeId) async {
    _validateRecipeId(recipeId);

    final response = await _dio.post<dynamic>(
      '/recipes/$recipeId/lock',
    );

    return _parseLock(response, recipeId);
  }

  @override
  Future<void> releaseLock(int recipeId) async {
    _validateRecipeId(recipeId);

    final response = await _dio.delete<dynamic>(
      '/recipes/$recipeId/lock',
    );

    if (response.statusCode != 204) {
      throw const FormatException('Unexpected lock release response.');
    }
  }

  RecipeEditLock _parseLock(
    Response<dynamic> response,
    int expectedRecipeId,
  ) {
    if (response.statusCode != 200 || response.data is! Map) {
      throw const FormatException('Unexpected recipe lock response.');
    }

    final lock = RecipeEditLock.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );

    if (lock.recipeId != expectedRecipeId) {
      throw const FormatException('Lock response belongs to another recipe.');
    }

    return lock;
  }

  void _validateRecipeId(int recipeId) {
    if (recipeId <= 0) {
      throw ArgumentError.value(recipeId, 'recipeId', 'Must be positive.');
    }
  }
}
