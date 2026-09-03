import '../../recipe/models/recipe.dart';
import '../../recipe/models/recipe_ingredient.dart';
import '../../recipe/models/recipe_step.dart';
import '../../recipe/models/unit_of_measurement.dart';
import '../../recipe/repositories/recipe_repository.dart';
import '../data/offline_cache_policy.dart';
import '../data/offline_cache_store.dart';

class CachedRecipeRepository implements RecipeRepository {
  CachedRecipeRepository({
    required RecipeRepository remote,
    required OfflineCacheStore cache,
    required int? viewerUserId,
  })  : _remote = remote,
        _cache = cache,
        _viewerUserId = viewerUserId;

  final RecipeRepository _remote;
  final OfflineCacheStore _cache;
  final int? _viewerUserId;

  @override
  Future<List<Recipe>> getRecipes() async {
    try {
      final recipes = await _remote.getRecipes();
      final viewerUserId = _viewerUserId;
      if (viewerUserId != null) {
        await _cache.replaceRecipeSummariesFromCompleteFetch(
          viewerUserId: viewerUserId,
          recipes: recipes,
          syncedAt: DateTime.now().toUtc(),
        );
      }
      return recipes;
    } catch (error) {
      final viewerUserId = _viewerUserId;
      if (!isOfflineTransportFailure(error) || viewerUserId == null) rethrow;
      return _cache.readRecipes(viewerUserId: viewerUserId);
    }
  }

  @override
  Future<Recipe> getRecipeById(int id) async {
    try {
      return await _remote.getRecipeById(id);
    } catch (error) {
      final cached = await _cachedRecipeForTransportFailure(error, id);
      if (cached == null) rethrow;
      return cached;
    }
  }

  @override
  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId) async {
    try {
      return await _remote.getRecipeIngredients(recipeId);
    } catch (error) {
      final cached = await _cachedRecipeForTransportFailure(error, recipeId);
      if (cached?.ingredients == null) rethrow;
      return cached!.ingredients!;
    }
  }

  @override
  Future<List<RecipeStep>> getRecipeSteps(int recipeId) async {
    try {
      return await _remote.getRecipeSteps(recipeId);
    } catch (error) {
      final cached = await _cachedRecipeForTransportFailure(error, recipeId);
      if (cached?.steps == null) rethrow;
      return cached!.steps!;
    }
  }

  Future<Recipe?> _cachedRecipeForTransportFailure(
    Object error,
    int recipeId,
  ) {
    final viewerUserId = _viewerUserId;
    if (!isOfflineTransportFailure(error) || viewerUserId == null) {
      return Future.value();
    }
    return _cache.readCompleteRecipe(
      viewerUserId: viewerUserId,
      recipeId: recipeId,
    );
  }

  @override
  Future<Recipe> addRecipe(Recipe recipe, int folderId) {
    return _remote.addRecipe(recipe, folderId);
  }

  @override
  Future<void> addRecipeIngredient(
    int recipeId,
    RecipeIngredient ingredient,
  ) {
    return _remote.addRecipeIngredient(recipeId, ingredient);
  }

  @override
  Future<void> addRecipeStep(int recipeId, RecipeStep step) {
    return _remote.addRecipeStep(recipeId, step);
  }

  @override
  Future<void> deleteRecipe(int recipeId) {
    return _remote.deleteRecipe(recipeId);
  }

  @override
  Future<List<String>> getCuisineTypes() {
    return _remote.getCuisineTypes();
  }

  @override
  Future<List<UnitOfMeasurement>> getUnits() {
    return _remote.getUnits();
  }

  @override
  Future<Recipe> updateRecipe(int id, Recipe recipe) {
    return _remote.updateRecipe(id, recipe);
  }

  @override
  Future<Recipe> updateRecipeFull(
    int id,
    Recipe recipe, {
    bool removePhoto = false,
  }) {
    return _remote.updateRecipeFull(
      id,
      recipe,
      removePhoto: removePhoto,
    );
  }
}
