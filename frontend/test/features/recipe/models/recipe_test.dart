import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

void main() {
  group('Recipe.fromJson', () {
    test('parses a full payload with camelCase keys', () {
      final json = <String, dynamic>{
        'recipeId': 1,
        'title': 'Saffron-Infused Risotto',
        'description': 'A rich Italian classic',
        'cuisineType': 'italian',
        'prepTimeMins': 15,
        'cookingTimeMins': 30,
        'servingSize': 4,
        'photoUrl': 'https://example.com/risotto.jpg',
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
        'recipeId': 99,
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

    test('parses ownerId and isCommunityPublished', () {
      final json = <String, dynamic>{
        'recipeId': 1,
        'title': 'Published Recipe',
        'ownerId': 42,
        'isCommunityPublished': true,
      };

      final recipe = Recipe.fromJson(json);

      expect(recipe.ownerId, 42);
      expect(recipe.isCommunityPublished, true);
    });

    test('defaults isCommunityPublished to false when absent', () {
      final json = <String, dynamic>{
        'recipeId': 2,
        'title': 'Unpublished',
      };

      final recipe = Recipe.fromJson(json);

      expect(recipe.isCommunityPublished, false);
    });


    test('parses nested ingredients and steps from a detail response', () {
      final json = <String, dynamic>{
        'recipeId': 1,
        'title': 'With Children',
        'ingredients': [
          {
            'ingredientId': 10,
            'recipeId': 1,
            'ingId': 16,
            'quantity': 320,
            'unit': 'g',
            'sortOrder': 1,
          },
        ],
        'steps': [
          {
            'stepId': 100,
            'recipeId': 1,
            'stepNr': 1,
            'content': 'Warm the stock.',
          },
        ],
      };

      final recipe = Recipe.fromJson(json);

      expect(recipe.ingredients, hasLength(1));
      expect(recipe.ingredients!.first.ingId, 16);
      expect(recipe.steps, hasLength(1));
      expect(recipe.steps!.first.content, 'Warm the stock.');
    });

    test('ignores extra JSON  keys not on the contract', () {
      //backend may send richer payloads; the model should silently drop them
      final json = <String, dynamic>{
        'recipeId': 1,
        'title': 'Extras',
        'chefName': 'Some chef',
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
      expect(recipe.isCommunityPublished, false);
    });
  });

  group('Recipe.toCreateRequestJson', () {
    test('emits the RecipeRequest metadata shape', () {
      const recipe = Recipe(
        recipeId: 0,
        title: 'New Dish',
        description: 'Tasty',
        cuisineType: 'italian',
        prepTimeMins: 10,
        cookingTimeMins: 20,
        servingSize: 4,
        isCommunityPublished: true,
      );

      final json = recipe.toCreateRequestJson();

      expect(json['title'], 'New Dish');
      expect(json['cuisineType'], 'italian');
      expect(json['prepTimeMins'], 10);
      expect(json['cookingTimeMins'], 20);
      expect(json['servingSize'], 4);
      expect(json['isCommunityPublished'], true);
      expect(json.containsKey('ingredients'), isFalse);
      expect(json.containsKey('steps'), isFalse);
    });
  });
}
