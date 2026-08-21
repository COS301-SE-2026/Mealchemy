import '../models/recipe_nutrition.dart';
import 'recipe_nutrition_repository.dart';

//mocked nutrition response until the backend GET endpoint is available
class MockRecipeNutritionRepository implements RecipeNutritionRepository {
  @override
  Future<RecipeNutrition> getRecipeNutrition(int recipeId) async {
    return RecipeNutrition(
      recipeId: recipeId,
      servings: 4,
      totals: const NutritionValues(
        caloriesKcal: 1167,
        proteinG: 33.5,
        carbsG: 110.3,
        fatG: 69.1,
        fibreG: 2,
        sodiumMg: 1804,
      ),
      perServing: const NutritionValues(
        caloriesKcal: 291.8,
        proteinG: 8.4,
        carbsG: 27.6,
        fatG: 17.3,
        fibreG: 0.5,
        sodiumMg: 451,
      ),
      ingredients: const [
        IngredientNutrition(
          ingredientId: 101,
          name: 'Chicken Breast Fillet',
          quantity: 300,
          unit: 'g',
          values: NutritionValues(
            caloriesKcal: 303,
            proteinG: 69,
            carbsG: 0,
            fatG: 3,
            fibreG: 0,
            sodiumMg: 210,
          ),
          percentOfRecipeCalories: 26,
        ),
        IngredientNutrition(
          ingredientId: 102,
          name: 'Soft Taco Shells',
          quantity: 8,
          unit: 'pieces',
          values: NutritionValues(
            caloriesKcal: 416,
            proteinG: 10,
            carbsG: 72,
            fatG: 10,
            fibreG: 4,
            sodiumMg: 760,
          ),
          percentOfRecipeCalories: 36,
        ),
        IngredientNutrition(
          ingredientId: 103,
          name: 'Cheddar Cheese',
          quantity: 120,
          unit: 'g',
          values: NutritionValues(
            caloriesKcal: 336,
            proteinG: 21,
            carbsG: 2,
            fatG: 27,
            fibreG: 0,
            sodiumMg: 720,
          ),
          percentOfRecipeCalories: 29,
        ),
        IngredientNutrition(
          ingredientId: 104,
          name: 'Romaine Lettuce',
          quantity: 1,
          unit: 'piece',
          values: NutritionValues(
            caloriesKcal: 42,
            proteinG: 3,
            carbsG: 8,
            fatG: 0.5,
            fibreG: 4,
            sodiumMg: 18,
          ),
          percentOfRecipeCalories: 4,
        ),
        IngredientNutrition(
          ingredientId: 105,
          name: 'Tomato Salsa',
          quantity: 150,
          unit: 'g',
          values: NutritionValues(
            caloriesKcal: 70,
            proteinG: 2,
            carbsG: 14,
            fatG: 0.6,
            fibreG: 3,
            sodiumMg: 360,
          ),
          percentOfRecipeCalories: 6,
        ),
      ],
    );
  }
}
