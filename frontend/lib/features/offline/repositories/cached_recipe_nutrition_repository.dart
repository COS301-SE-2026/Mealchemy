import '../../recipe/models/recipe_nutrition.dart';
import '../../recipe/repositories/recipe_nutrition_repository.dart';
import '../data/offline_cache_policy.dart';
import '../data/offline_cache_store.dart';

class CachedRecipeNutritionRepository implements RecipeNutritionRepository {
  CachedRecipeNutritionRepository({
    required RecipeNutritionRepository remote,
    required OfflineCacheStore cache,
    required int viewerUserId,
  })  : _remote = remote,
        _cache = cache,
        _viewerUserId = viewerUserId;

  final RecipeNutritionRepository _remote;
  final OfflineCacheStore _cache;
  final int _viewerUserId;

  @override
  Future<RecipeNutrition> getRecipeNutrition(int recipeId) async {
    try {
      final nutrition = await _remote.getRecipeNutrition(recipeId);
      await _cache.storeRecipeNutrition(
        viewerUserId: _viewerUserId,
        nutrition: nutrition,
        syncedAt: DateTime.now().toUtc(),
      );
      return nutrition;
    } catch (error) {
      if (!isOfflineTransportFailure(error)) rethrow;
      final cached = await _cache.readRecipeNutrition(
        viewerUserId: _viewerUserId,
        recipeId: recipeId,
      );
      if (cached == null) rethrow;
      return cached;
    }
  }
}
