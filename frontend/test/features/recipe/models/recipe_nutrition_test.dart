import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe_nutrition.dart';

void main() {
  test('RecipeNutrition maps complete backend-shaped response', () {
    final nutrition = RecipeNutrition.fromJson({
      'recipe_id': 42,
      'servings': 4,
      'totals': {
        'calories_kcal': 1167,
        'protein_g': 33.5,
        'carbs_g': 110.3,
        'fat_g': 69.1,
        'fibre_g': 2,
        'sodium_mg': 1804,
      },
      'per_serving': {
        'calories_kcal': 292,
        'protein_g': 8.4,
        'carbs_g': 27.6,
        'fat_g': 17.3,
        'fibre_g': 0.5,
        'sodium_mg': 451,
      },
      'ingredients': [
        {
          'ing_id': 101,
          'name': 'Chicken Breast Fillet',
          'quantity': 300,
          'unit': 'g',
          'calories_kcal': 303,
          'protein_g': 69,
          'carbs_g': 0,
          'fat_g': 3,
          'fibre_g': 0,
          'sodium_mg': 210,
        },
      ],
    });

    expect(nutrition.recipeId, 42);
    expect(nutrition.servings, 4);

    expect(nutrition.totals.caloriesKcal, 1167);
    expect(nutrition.totals.proteinG, 33.5);
    expect(nutrition.totals.carbsG, 110.3);
    expect(nutrition.totals.fatG, 69.1);
    expect(nutrition.totals.fibreG, 2);
    expect(nutrition.totals.sodiumMg, 1804);

    expect(nutrition.perServing.caloriesKcal, 292);
    expect(nutrition.perServing.proteinG, 8.4);
    expect(nutrition.perServing.carbsG, 27.6);
    expect(nutrition.perServing.fatG, 17.3);
    expect(nutrition.perServing.fibreG, 0.5);
    expect(nutrition.perServing.sodiumMg, 451);

    expect(nutrition.ingredients, hasLength(1));

    final ingredient = nutrition.ingredients.first;

    expect(ingredient.ingredientId, 101);
    expect(ingredient.name, 'Chicken Breast Fillet');
    expect(ingredient.quantity, 300);
    expect(ingredient.unit, 'g');
    expect(ingredient.values.caloriesKcal, 303);
    expect(ingredient.values.proteinG, 69);
    expect(ingredient.values.carbsG, 0);
    expect(ingredient.values.fatG, 3);
    expect(ingredient.values.fibreG, 0);
    expect(ingredient.values.sodiumMg, 210);
    expect(
      ingredient.percentOfRecipeCalories,
      closeTo(25.96, 0.01),
    );
  });

  test('RecipeNutrition safely maps numeric strings and empty ingredients', () {
    final nutrition = RecipeNutrition.fromJson({
      'recipe_id': '7',
      'servings': '2',
      'totals': {
        'calories_kcal': '500.5',
        'protein_g': '25',
        'carbs_g': '60',
        'fat_g': '18.5',
        'fibre_g': '7',
        'sodium_mg': '640',
      },
      'per_serving': {
        'calories_kcal': '250.25',
        'protein_g': '12.5',
        'carbs_g': '30',
        'fat_g': '9.25',
        'fibre_g': '3.5',
        'sodium_mg': '320',
      },
      'ingredients': [],
    });

    expect(nutrition.recipeId, 7);
    expect(nutrition.servings, 2);
    expect(nutrition.totals.caloriesKcal, 500.5);
    expect(nutrition.perServing.caloriesKcal, 250.25);
    expect(nutrition.ingredients, isEmpty);
  });

  test('RecipeNutrition uses zero contribution when total calories are zero',
      () {
    final nutrition = RecipeNutrition.fromJson({
      'recipe_id': 8,
      'servings': 1,
      'totals': {
        'calories_kcal': 0,
        'protein_g': 0,
        'carbs_g': 0,
        'fat_g': 0,
        'fibre_g': 0,
        'sodium_mg': 0,
      },
      'per_serving': {
        'calories_kcal': 0,
        'protein_g': 0,
        'carbs_g': 0,
        'fat_g': 0,
        'fibre_g': 0,
        'sodium_mg': 0,
      },
      'ingredients': [
        {
          'ing_id': 101,
          'name': 'Water',
          'quantity': 100,
          'unit': 'ml',
          'calories_kcal': 0,
          'protein_g': 0,
          'carbs_g': 0,
          'fat_g': 0,
          'fibre_g': 0,
          'sodium_mg': 0,
        },
      ],
    });

    expect(
      nutrition.ingredients.single.percentOfRecipeCalories,
      0,
    );
  });
}
