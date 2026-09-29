import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import 'package:mealchemy/features/offline/data/offline_cache_database.dart';
import 'package:mealchemy/features/offline/data/offline_cache_store.dart';
import 'package:mealchemy/features/offline/providers/offline_cache_provider.dart';
import 'package:mealchemy/features/offline/repositories/cached_recipe_nutrition_repository.dart';
import 'package:mealchemy/features/recipe/models/recipe_nutrition.dart';
import 'package:mealchemy/features/recipe/providers/recipe_nutrition_provider.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_nutrition_repository.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';
import 'package:mealchemy/features/recipe/repositories/mock_recipe_nutrition_repository.dart';

class _RecordingNutritionRepository implements RecipeNutritionRepository {
  int? requestedRecipeId;

  @override
  Future<RecipeNutrition> getRecipeNutrition(int recipeId) async {
    requestedRecipeId = recipeId;

    return RecipeNutrition(
      recipeId: recipeId,
      servings: 2,
      totals: const NutritionValues(
        caloriesKcal: 600,
        proteinG: 30,
        carbsG: 70,
        fatG: 20,
        fibreG: 8,
        sodiumMg: 900,
      ),
      perServing: const NutritionValues(
        caloriesKcal: 300,
        proteinG: 15,
        carbsG: 35,
        fatG: 10,
        fibreG: 4,
        sodiumMg: 450,
      ),
      ingredients: const [],
    );
  }
}

void main() {
  test('nutrition repository uses mock when Recipe mock mode is enabled', () {
    final container = ProviderContainer(
      overrides: [
        mockRecipeEnabledProvider.overrideWithValue(true),
      ],
    );
    addTearDown(container.dispose);

    final repository = container.read(
      recipeNutritionRepositoryProvider,
    );

    expect(repository, isA<MockRecipeNutritionRepository>());
  });

  test('nutrition repository uses remote repository in API mode', () {
    final remoteRepository = _RecordingNutritionRepository();

    final container = ProviderContainer(
      overrides: [
        mockRecipeEnabledProvider.overrideWithValue(false),
        remoteRecipeNutritionRepositoryProvider.overrideWithValue(
          remoteRepository,
        ),
      ],
    );
    addTearDown(container.dispose);

    final repository = container.read(
      recipeNutritionRepositoryProvider,
    );

    expect(repository, same(remoteRepository));
  });

  test('nutrition repository decorates API mode for authenticated users', () {
    final remoteRepository = _RecordingNutritionRepository();
    final database = OfflineCacheDatabase(NativeDatabase.memory());
    final cache = OfflineCacheStore(database);
    addTearDown(database.close);

    final container = ProviderContainer(
      overrides: [
        mockRecipeEnabledProvider.overrideWithValue(false),
        activeIdentityProvider.overrideWithValue(11),
        offlineCacheStoreProvider.overrideWithValue(cache),
        remoteRecipeNutritionRepositoryProvider.overrideWithValue(
          remoteRepository,
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(recipeNutritionRepositoryProvider),
      isA<CachedRecipeNutritionRepository>(),
    );
  });

  test('recipeNutritionProvider loads nutrition for requested recipe',
      () async {
    final repository = _RecordingNutritionRepository();

    final container = ProviderContainer(
      overrides: [
        recipeNutritionRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final nutrition = await container.read(
      recipeNutritionProvider(42).future,
    );

    expect(repository.requestedRecipeId, 42);
    expect(nutrition.recipeId, 42);
    expect(nutrition.servings, 2);
    expect(nutrition.totals.caloriesKcal, 600);
    expect(nutrition.perServing.caloriesKcal, 300);
  });
}
