import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/offline/data/offline_cache_database.dart';
import 'package:mealchemy/features/offline/data/offline_cache_store.dart';
import 'package:mealchemy/features/offline/repositories/cached_recipe_repository.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';
import 'package:mealchemy/features/recipe/repositories/mock_recipe_repository.dart';

void main() {
  late OfflineCacheDatabase database;
  late OfflineCacheStore cache;

  setUp(() {
    database = OfflineCacheDatabase(NativeDatabase.memory());
    cache = OfflineCacheStore(database);
  });

  tearDown(() => database.close());

  test('successful list fetch refreshes only the viewer cache', () async {
    final remote = _RecipeRemote(recipe: _recipe('Fresh API recipe'));
    final repository = CachedRecipeRepository(
      remote: remote,
      cache: cache,
      viewerUserId: 11,
    );

    final result = await repository.getRecipes();

    expect(result.single.title, 'Fresh API recipe');
    expect(
      (await cache.readRecipes(viewerUserId: 11)).single.title,
      'Fresh API recipe',
    );
    expect(await cache.readRecipes(viewerUserId: 12), isEmpty);
  });

  test('transport list failure returns cached summaries', () async {
    await cache.replaceRecipeSummariesFromCompleteFetch(
      viewerUserId: 11,
      recipes: [_recipe('Cached recipe')],
      syncedAt: DateTime.now().toUtc(),
    );
    final repository = CachedRecipeRepository(
      remote: _RecipeRemote(
        recipe: _recipe('Remote recipe'),
        listError: _connectionError(),
      ),
      cache: cache,
      viewerUserId: 11,
    );

    final result = await repository.getRecipes();

    expect(result.single.title, 'Cached recipe');
  });

  test('HTTP list errors propagate instead of returning stale recipes',
      () async {
    final error = _httpError(500);
    final repository = CachedRecipeRepository(
      remote: _RecipeRemote(recipe: _recipe('Remote'), listError: error),
      cache: cache,
      viewerUserId: 11,
    );

    await expectLater(repository.getRecipes(), throwsA(same(error)));
  });

  test('complete cached aggregate backs detail ingredients and steps',
      () async {
    final cachedRecipe = _recipe('Complete cached recipe', complete: true);
    await cache.storeCompleteRecipe(
      viewerUserId: 11,
      recipe: cachedRecipe,
      syncedAt: DateTime.now().toUtc(),
    );
    final remote = _RecipeRemote(
      recipe: _recipe('Remote'),
      detailError: _connectionError(),
    );
    final repository = CachedRecipeRepository(
      remote: remote,
      cache: cache,
      viewerUserId: 11,
    );

    expect((await repository.getRecipeById(7)).title, 'Complete cached recipe');
    expect((await repository.getRecipeIngredients(7)).single.name, 'Milk');
    expect((await repository.getRecipeSteps(7)).single.content, 'Mix');
  });

  test('missing aggregate and anonymous viewers rethrow transport failures',
      () async {
    final error = _connectionError();
    final remote = _RecipeRemote(
      recipe: _recipe('Remote'),
      detailError: error,
    );
    final repository = CachedRecipeRepository(
      remote: remote,
      cache: cache,
      viewerUserId: 11,
    );
    final anonymousRepository = CachedRecipeRepository(
      remote: remote,
      cache: cache,
      viewerUserId: null,
    );

    await expectLater(repository.getRecipeById(7), throwsA(same(error)));
    await expectLater(
      anonymousRepository.getRecipeIngredients(7),
      throwsA(same(error)),
    );
  });

  test('forwards reference and mutation methods to the remote repository',
      () async {
    final remote = _RecipeRemote(recipe: _recipe('Remote', complete: true));
    final repository = CachedRecipeRepository(
      remote: remote,
      cache: cache,
      viewerUserId: 11,
    );
    final recipe = _recipe('Mutation', complete: true);
    final ingredient = recipe.ingredients!.single;
    final step = recipe.steps!.single;

    expect((await repository.addRecipe(recipe, 3)).title, 'Mutation');
    await repository.addRecipeIngredient(7, ingredient);
    await repository.addRecipeStep(7, step);
    await repository.deleteRecipe(7);
    expect(await repository.getCuisineTypes(), isNotEmpty);
    expect(await repository.getUnits(), isNotEmpty);
    expect((await repository.updateRecipe(7, recipe)).recipeId, 7);
    expect(
      (await repository.updateRecipeFull(7, recipe, removePhoto: true))
          .recipeId,
      7,
    );
  });
}

Recipe _recipe(String title, {bool complete = false}) => Recipe(
      recipeId: 7,
      ownerId: 99,
      title: title,
      description: 'Description',
      cuisineType: 'other',
      prepTimeMins: 5,
      cookingTimeMins: 10,
      servingSize: 2,
      ingredients: complete
          ? const [
              RecipeIngredient(
                ingredientId: 1,
                recipeId: 7,
                ingId: 8,
                name: 'Milk',
                quantity: 1,
                unit: 'L',
                sortOrder: 0,
              ),
            ]
          : null,
      steps: complete
          ? const [
              RecipeStep(
                stepId: 1,
                recipeId: 7,
                stepNr: 1,
                content: 'Mix',
              ),
            ]
          : null,
    );

class _RecipeRemote extends MockRecipeRepository {
  _RecipeRemote({
    required this.recipe,
    this.listError,
    this.detailError,
  });

  final Recipe recipe;
  final Object? listError;
  final Object? detailError;

  @override
  Future<List<Recipe>> getRecipes() async {
    if (listError case final error?) throw error;
    return [recipe.copyWith(ingredients: null, steps: null)];
  }

  @override
  Future<Recipe> getRecipeById(int id) async {
    if (detailError case final error?) throw error;
    return recipe;
  }

  @override
  Future<List<RecipeIngredient>> getRecipeIngredients(int recipeId) async {
    if (detailError case final error?) throw error;
    return recipe.ingredients ?? const [];
  }

  @override
  Future<List<RecipeStep>> getRecipeSteps(int recipeId) async {
    if (detailError case final error?) throw error;
    return recipe.steps ?? const [];
  }

  @override
  Future<Recipe> addRecipe(Recipe recipe, int folderId) async => recipe;
}

DioException _connectionError() => DioException(
      requestOptions: RequestOptions(path: '/recipes'),
      type: DioExceptionType.connectionError,
    );

DioException _httpError(int statusCode) => DioException.badResponse(
      statusCode: statusCode,
      requestOptions: RequestOptions(path: '/recipes'),
      response: Response<void>(
        requestOptions: RequestOptions(path: '/recipes'),
        statusCode: statusCode,
      ),
    );
