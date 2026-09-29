import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/favourites/models/favourite.dart';

void main() {
  group('Favourite.fromJson', () {
    Map<String, dynamic> likedItem() => {
          'recipe_id': 42,
          'cuisine_value': 'italian',
          'liked_at': '2026-02-14T08:30:00Z',
          'recipe': {
            'recipeId': 42,
            'title': 'Test Pasta',
            'cuisineType': 'italian',
            'prepTimeMins': 10,
            'cookingTimeMins': 20,
          },
        };

    test('parses recipe_id, liked_at and the nested recipe', () {
      final fav = Favourite.fromJson(likedItem());

      expect(fav.recipeId, 42);
      expect(fav.createdAt, DateTime.parse('2026-02-14T08:30:00Z'));
      expect(fav.recipe.recipeId, 42);
      expect(fav.recipe.title, 'Test Pasta');
      expect(fav.recipe.cuisineType, 'italian');
    });
    test('parses cuisine_value for unlike swipes', () {
      final fav = Favourite.fromJson(likedItem());
      expect(fav.cuisineValue, 'italian');
    });

    test('missing cuisine_value falls back to OTHER', () {
      final json = likedItem()..remove('cuisine_value');
      final fav = Favourite.fromJson(json);
      expect(fav.cuisineValue, 'OTHER');
    });

    test(
        'favouriteId mirrors recipeId (liked response carries no favourite id)',
        () {
      final fav = Favourite.fromJson(likedItem());

      expect(fav.favouriteId, fav.recipeId);
    });
  });
}
