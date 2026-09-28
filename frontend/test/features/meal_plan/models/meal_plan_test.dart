import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/meal_plan/models/meal_plan.dart';

void main() {
  test('MealPlan.fromJson reads plan and vault ids', () {
    final plan = MealPlan.fromJson({'planId': 7, 'vaultId': 3});

    expect(plan.planId, 7);
    expect(plan.vaultId, 3);
  });

  group('MealSuggestion.fromJson', () {
    test('reads the recipe, cuisine and score breakdown', () {
      final s = MealSuggestion.fromJson({
        'recipeId': 981,
        'cuisineType': 'ITALIAN',
        'scoreBreakdown': {
          'pantry_match': 0.6,
          'cuisine': 0.8,
          'nutrition': 0.5,
          'freshness': 0.7,
          'novelty': 0.4,
        },
        'recipe': {
          'recipeId': 981,
          'title': 'Penne Alla Vodka',
          'cuisineType': 'ITALIAN',
        },
      });

      expect(s.recipe.recipeId, 981);
      expect(s.recipe.title, 'Penne Alla Vodka');
      expect(s.cuisineType, 'ITALIAN');
      expect(s.scoreBreakdown['pantry_match'], 0.6);
      expect(s.scoreBreakdown.keys,
          containsAll(['pantry_match', 'cuisine', 'nutrition', 'freshness', 'novelty']));
    });

    test('falls back to the recipe cuisine, then OTHER', () {
      final fromRecipe = MealSuggestion.fromJson({
        'recipe': {'recipeId': 1, 'title': 'Chana Masala', 'cuisineType': 'INDIAN'},
      });
      final fallback = MealSuggestion.fromJson({
        'recipe': {'recipeId': 2, 'title': 'Test Pasta'},
      });

      expect(fromRecipe.cuisineType, 'INDIAN');
      expect(fallback.cuisineType, 'OTHER');
    });

    test('missing score breakdown becomes an empty map', () {
      final s = MealSuggestion.fromJson({
        'cuisineType': 'MEXICAN',
        'recipe': {'recipeId': 3, 'title': 'Burrito Bowl'},
      });

      expect(s.scoreBreakdown, isEmpty);
    });
  });
}