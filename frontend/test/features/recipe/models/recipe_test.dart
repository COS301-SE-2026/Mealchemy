import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

void main() {
  group('Recipe.fromJson', () {
    test('parses a full payload with snake_case keys', () {
      final json = <String, dynamic>{
        'recipe_id': 1,
        'title': 'Saffron-Infused Risotto',
        'description': 'A rich Italian classic',
        'cuisine_type': 'italian',
        'prep_time_mins': 15,
        'cooking_time_mins': 30,
        'serving_size': 4,
        'photo_url': 'https://example.com/risotto.jpg',
      };

      final recipe = Recipe.fromJson(json);

      expect(recipe.recipeId, 1);
      expect(recipe.title, 'Saffron-Infused Risotto');
      expect(recipe.description, 'A rich Italian classic');
      expect(recipe.cuisineType, 'italian');
      expect(recipe.prepTimeMins, 15);
      expect(recipe.cookingTimeMins, 30);
      expect(recipe.servingSize, 4);
      expect(recipe.photoUrl, 'https://example.com/risotto.jpg');
    });

    test('parses a minimal payload with only required fields', () {
      final json = <String, dynamic>{
        'recipe_id': 99,
        'title': 'Minimal Recipe',
      };

      final recipe = Recipe.fromJson(json);

      expect(recipe.recipeId, 99);
      expect(recipe.title, 'Minimal Recipe');
      expect(recipe.description, isNull);
      expect(recipe.cuisineType, isNull);
      expect(recipe.prepTimeMins, isNull);
      expect(recipe.cookingTimeMins, isNull);
      expect(recipe.servingSize, isNull);
      expect(recipe.photoUrl, isNull);
      expect(recipe.ingredients, isNull);
      expect(recipe.steps, isNull);
    });

    test('parses nested ingredients and steps from a detail response', () {
      final json = <String, dynamic>{
        'recipe_id': 1,
        'title': 'With Children',
        'ingredients': [
          {
            'ingredient_id': 10,
            'recipe_id': 1,
            'name_raw': 'Arborio rice',
            'quantity': 320,
            'unit': 'g',
            'sort_order': 1,
          },
        ],
        'steps': [
          {
            'step_id': 100,
            'recipe_id': 1,
            'step_nr': 1,
            'content': 'Warm the stock.',
          },
        ],
      };

      final recipe = Recipe.fromJson(json);

      expect(recipe.ingredients, hasLength(1));
      expect(recipe.ingredients!.first.nameRaw, 'Arborio rice');
      expect(recipe.steps, hasLength(1));
      expect(recipe.steps!.first.content, 'Warm the stock.');
    });

    test('ignores extra JSON keys not on the lightweight contract', () {
      //backend may send richer payloads; the model should silently drop them
      final json = <String, dynamic>{
        'recipe_id': 1,
        'title': 'Extras',
        'owner_id': 42,
        'chef_name': 'Some chef',
        'rating': 4.8,
      };

      final recipe = Recipe.fromJson(json);

      expect(recipe.recipeId, 1);
      expect(recipe.title, 'Extras');
    });
  });

  group('Recipe constructor', () {
    test('creates an instance with only required fields', () {
      const recipe = Recipe(recipeId: 7, title: 'Tiny');

      expect(recipe.recipeId, 7);
      expect(recipe.title, 'Tiny');
      expect(recipe.ingredients, isNull);
      expect(recipe.steps, isNull);
    });
  });
}
