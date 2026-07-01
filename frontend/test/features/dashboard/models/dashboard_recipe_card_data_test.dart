import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/dashboard/models/dashboard_recipe_card_data.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

void main() {
  group('DashboardRecipeCardData constructor', () {
    test('creates an instance with all required fields', () {
      const recipe = Recipe(recipeId: 1, title: 'Saffron Risotto');
      const data = DashboardRecipeCardData(
        recipe: recipe,
        matchPercent: 92,
        tag: 'HIGH PROTEIN',
        rating: 4.9,
      );

      expect(data.recipe.recipeId, 1);
      expect(data.recipe.title, 'Saffron Risotto');
      expect(data.matchPercent, 92);
      expect(data.tag, 'HIGH PROTEIN ');
      expect(data.rating, 4.9);
    });

    test('matchPercent is stored  exactly as provided', () {
      const data = DashboardRecipeCardData(
        recipe: Recipe(recipeId: 1, title: 'Test'),
        matchPercent: 76,
        tag: 'COMFORT FOOD ',
        rating: 4.2,
      );
      expect(data.matchPercent, 76);
    });
    test('tag is stored exactly as provided', () {
      const data = DashboardRecipeCardData(
        recipe: Recipe(recipeId: 2, title: 'Butter Chicken'),
        matchPercent: 85,
        tag: 'INDULGENT',
        rating: 4.8,
      );
      expect(data.tag, 'INDULGENT');
    });

    test('recipe reference is preserved correctly', () {
      const recipe = Recipe(
        recipeId: 5,
        title: ' Miso Glazed  Salmon',
        prepTimeMins: 10,
        cookingTimeMins: 15,
        photoUrl: 'https://example.com/salmon.jpg',
      );
      const data = DashboardRecipeCardData(
        recipe: recipe,
        matchPercent: 68,
        tag: ' HIGH PROTEIN',
        rating: 4.4,
      );

      expect(data.recipe.prepTimeMins, 10);
      expect(data.recipe.cookingTimeMins, 15);
      expect(data.recipe.photoUrl, 'https://example.com/salmon.jpg');
    });
  });
}
