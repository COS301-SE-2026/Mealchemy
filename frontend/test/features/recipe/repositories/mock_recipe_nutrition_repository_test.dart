import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/repositories/mock_recipe_nutrition_repository.dart';

void main() {
  test('MockRecipeNutritionRepository returns nutrition for requested recipe',
      () async {
    final repository = MockRecipeNutritionRepository();

    final nutrition = await repository.getRecipeNutrition(42);

    expect(nutrition.recipeId, 42);
    expect(nutrition.servings, 4);
    expect(nutrition.totals.caloriesKcal, 1167);
    expect(nutrition.perServing.caloriesKcal, 291.8);
    expect(nutrition.ingredients, isNotEmpty);
    expect(nutrition.ingredients.first.name, 'Chicken Breast Fillet');
  });
}
