import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import 'package:mealchemy/features/offline/data/offline_cache_database.dart';
import 'package:mealchemy/features/offline/data/offline_cache_store.dart';
import 'package:mealchemy/features/offline/providers/offline_cache_provider.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';
import 'package:mealchemy/features/recipe/models/unit_of_measurement.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_repository.dart';

void main() {
  late OfflineCacheDatabase database;
  late OfflineCacheStore cache;

  setUp(() {
    database = OfflineCacheDatabase(NativeDatabase.memory());
    cache = OfflineCacheStore(database);
  });

  tearDown(() => database.close());

  test('partial network assembly keeps and returns the previous aggregate',
      () async {
    await cache.storeCompleteRecipe(
      viewerUserId: 11,
      recipe: _completeRecipe('Previously cached'),
      syncedAt: DateTime.now().toUtc(),
    );
    final remote = _RecipeRepositoryStub(
      recipeResult: () async => const Recipe(recipeId: 42, title: 'Fresh'),
      ingredientsResult: () => Future.error(_connectionError()),
      stepsResult: () async => const [
        RecipeStep(recipeId: 42, stepNr: 1, content: 'Fresh step'),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        activeIdentityProvider.overrideWithValue(11),
        offlineCacheStoreProvider.overrideWithValue(cache),
        remoteRecipeRepositoryProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(recipeDetailProvider(42).future);

    expect(result.title, 'Previously cached');
    expect(result.ingredients?.single.name, 'Salt');
    expect(result.steps?.single.content, 'Cached step');
    final persisted =
        await cache.readCompleteRecipe(viewerUserId: 11, recipeId: 42);
    expect(persisted?.title, 'Previously cached');
  });
}

Recipe _completeRecipe(String title) => Recipe(
      recipeId: 42,
      title: title,
      ingredients: const [
        RecipeIngredient(
          recipeId: 42,
          ingId: 5,
          name: 'Salt',
          sortOrder: 0,
        ),
      ],
      steps: const [
        RecipeStep(
          recipeId: 42,
          stepNr: 1,
          content: 'Cached step',
        ),
      ],
    );

DioException _connectionError() => DioException(
      requestOptions: RequestOptions(path: '/ingredients/recipe/42'),
      type: DioExceptionType.connectionError,
    );

class _RecipeRepositoryStub implements RecipeRepository {
  _RecipeRepositoryStub({
    required this.recipeResult,
    required this.ingredientsResult,
    required this.stepsResult,
  });

  final Future<Recipe> Function() recipeResult;
  final Future<List<RecipeIngredient>> Function() ingredientsResult;
  final Future<List<RecipeStep>> Function() stepsResult;

  @override
  Future<Recipe> getRecipeById(int id) => recipeResult();
  @override
  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId) =>
      ingredientsResult();
  @override
  Future<List<RecipeStep>> getRecipeSteps(int recipeId) => stepsResult();

  @override
  Future<Recipe> addRecipe(Recipe recipe, int folderId) =>
      throw UnimplementedError();
  @override
  Future<void> addRecipeIngredient(int recipeId, RecipeIngredient ingredient) =>
      throw UnimplementedError();
  @override
  Future<void> addRecipeStep(int recipeId, RecipeStep step) =>
      throw UnimplementedError();
  @override
  Future<void> deleteRecipe(int recipeId) => throw UnimplementedError();
  @override
  Future<List<String>> getCuisineTypes() => throw UnimplementedError();
  @override
  Future<List<Recipe>> getRecipes() => throw UnimplementedError();
  @override
  Future<List<UnitOfMeasurement>> getUnits() => throw UnimplementedError();
  @override
  Future<Recipe> updateRecipe(int id, Recipe recipe) =>
      throw UnimplementedError();
  @override
  Future<Recipe> updateRecipeFull(
    int id,
    Recipe recipe, {
    bool removePhoto = false,
  }) =>
      throw UnimplementedError();
}
