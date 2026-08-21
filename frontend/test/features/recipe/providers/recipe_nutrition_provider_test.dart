import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe_nutrition.dart';
import 'package:mealchemy/features/recipe/providers/recipe_nutrition_provider.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_nutrition_repository.dart';

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
