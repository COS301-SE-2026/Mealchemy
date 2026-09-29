import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/offline/data/offline_cache_database.dart';
import 'package:mealchemy/features/offline/data/offline_cache_store.dart';
import 'package:mealchemy/features/offline/repositories/cached_recipe_nutrition_repository.dart';
import 'package:mealchemy/features/recipe/models/recipe_nutrition.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_nutrition_repository.dart';

void main() {
  late OfflineCacheDatabase database;
  late OfflineCacheStore cache;

  setUp(() {
    database = OfflineCacheDatabase(NativeDatabase.memory());
    cache = OfflineCacheStore(database);
  });

  tearDown(() => database.close());

  test('successful fetch refreshes the viewer nutrition cache', () async {
    final nutrition = _nutrition();
    final repository = CachedRecipeNutritionRepository(
      remote: _NutritionRemote(nutrition: nutrition),
      cache: cache,
      viewerUserId: 11,
    );

    final result = await repository.getRecipeNutrition(42);

    expect(result, same(nutrition));
    expect(
      (await cache.readRecipeNutrition(viewerUserId: 11, recipeId: 42))
          ?.totals
          .caloriesKcal,
      600,
    );
    expect(
      await cache.readRecipeNutrition(viewerUserId: 12, recipeId: 42),
      isNull,
    );
  });

  test('transport failure returns the cached nutrition summary', () async {
    await cache.storeRecipeNutrition(
      viewerUserId: 11,
      nutrition: _nutrition(),
      syncedAt: DateTime.now().toUtc(),
    );
    final repository = CachedRecipeNutritionRepository(
      remote: _NutritionRemote(error: _connectionError()),
      cache: cache,
      viewerUserId: 11,
    );

    final result = await repository.getRecipeNutrition(42);

    expect(result.perServing.caloriesKcal, 300);
    expect(result.ingredients, isEmpty);
  });

  test('missing cache and HTTP errors propagate', () async {
    final transportError = _connectionError();
    final missingRepository = CachedRecipeNutritionRepository(
      remote: _NutritionRemote(error: transportError),
      cache: cache,
      viewerUserId: 11,
    );
    final httpError = _httpError(500);
    final httpRepository = CachedRecipeNutritionRepository(
      remote: _NutritionRemote(error: httpError),
      cache: cache,
      viewerUserId: 11,
    );

    await expectLater(
      missingRepository.getRecipeNutrition(42),
      throwsA(same(transportError)),
    );
    await expectLater(
      httpRepository.getRecipeNutrition(42),
      throwsA(same(httpError)),
    );
  });
}

class _NutritionRemote implements RecipeNutritionRepository {
  _NutritionRemote({this.nutrition, this.error});

  final RecipeNutrition? nutrition;
  final Object? error;

  @override
  Future<RecipeNutrition> getRecipeNutrition(int recipeId) async {
    if (error case final value?) throw value;
    return nutrition!;
  }
}

RecipeNutrition _nutrition() => const RecipeNutrition(
      recipeId: 42,
      servings: 2,
      totals: NutritionValues(
        caloriesKcal: 600,
        proteinG: 30,
        carbsG: 70,
        fatG: 20,
        fibreG: 8,
        sodiumMg: 900,
      ),
      perServing: NutritionValues(
        caloriesKcal: 300,
        proteinG: 15,
        carbsG: 35,
        fatG: 10,
        fibreG: 4,
        sodiumMg: 450,
      ),
      ingredients: [],
    );

DioException _connectionError() => DioException(
      requestOptions: RequestOptions(path: '/nutrition/42'),
      type: DioExceptionType.connectionError,
    );

DioException _httpError(int statusCode) => DioException.badResponse(
      statusCode: statusCode,
      requestOptions: RequestOptions(path: '/nutrition/42'),
      response: Response<void>(
        requestOptions: RequestOptions(path: '/nutrition/42'),
        statusCode: statusCode,
      ),
    );
