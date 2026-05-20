import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

void main() {
  group('Recipe.fromJson', () {
    test('parses a full payload with snake_case keys', () {
      final json = <String, dynamic>{
        'recipe_id': 1,
        'owner_id': 42,
        'title': 'Saffron-Infused Risotto',
        'description': 'A rich Italian classic',
        'cuisine_type': 'italian',
        'prep_time_mins': 15,
        'cooking_time_mins': 30,
        'serving_size': 4,
        'photo_url': 'https://example.com/risotto.jpg',
        'video_url': 'https://example.com/risotto.mp4',
        'is_community_published': true,
        'chef_name': 'Chef Isabella V.',
        'chef_avatar_url': 'https://example.com/chef.png',
        'rating': 4.8,
        'rating_count': 124,
      };

      final recipe = Recipe.fromJson(json);

      expect(recipe.recipeId, 1);
      expect(recipe.ownerId, 42);
      expect(recipe.title, 'Saffron-Infused Risotto');
      expect(recipe.description, 'A rich Italian classic');
      expect(recipe.cuisineType, 'italian');
      expect(recipe.prepTimeMins, 15);
      expect(recipe.cookingTimeMins, 30);
      expect(recipe.servingSize, 4);
      expect(recipe.photoUrl, 'https://example.com/risotto.jpg');
      expect(recipe.videoUrl, 'https://example.com/risotto.mp4');
      expect(recipe.isCommunityPublished, true);
      expect(recipe.chefName, 'Chef Isabella V.');
      expect(recipe.chefAvatarUrl, 'https://example.com/chef.png');
      expect(recipe.rating, 4.8);
      expect(recipe.ratingCount, 124);
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
      expect(recipe.videoUrl, isNull);
      expect(recipe.isCommunityPublished, isNull);
      expect(recipe.ingredients, isNull);
      expect(recipe.steps, isNull);
      expect(recipe.chefName, isNull);
      expect(recipe.rating, isNull);
    });

    test('parses nested ingredients and steps from list response', () {
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

    test('coerces integer rating value to double', () {
      //backend may have 5 not 5.0
      final json = <String, dynamic>{
        'recipe_id': 1,
        'title': 'Whole Rating',
        'rating': 5,
      };

      final recipe = Recipe.fromJson(json);

      expect(recipe.rating, 5.0);
      expect(recipe.rating, isA<double>());
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
