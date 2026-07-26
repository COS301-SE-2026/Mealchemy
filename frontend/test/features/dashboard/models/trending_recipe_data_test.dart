import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/dashboard/models/trending_recipe_data.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';


void main() {

  group('TrendType  enum', () {
    test('has trendngNow  value ', () {
      expect(TrendType.trendingNow, isNotNull);
    });
    test('has  editorChoice value', () {
      expect(TrendType.editorsChoice, isNotNull);
    });
    test('trendingNow and  editorsChoice are distinct', () {
      expect(TrendType.trendingNow, isNot(TrendType.editorsChoice));
    });
  });

  group('TrendingRecipeData  constructor', () {
    test('creates a instance with  trendingNow type', () {
      
      const recipe = Recipe(recipeId: 3,  title: 'Avocado & Kale Superbowl');
      const data = TrendingRecipeData(
        recipe: recipe,
        trendType:  TrendType.trendingNow,
        subtitle: '4.2k saves this week ',

      );

      expect(data.recipe.recipeId, 3);
      expect(data.trendType, TrendType.trendingNow);
      expect(data.subtitle, '4.2k saves this week ');

    });

    test('creates an instance with editorsChoice type', () {
      const recipe = Recipe(recipeId: 5,  title: 'Dark Chocolate & Gold  Ganache');
      const data = TrendingRecipeData(
        recipe: recipe,
        trendType:   TrendType.editorsChoice,
        subtitle:  'New seasonal favourite ',
      );
      expect(data.trendType, TrendType.editorsChoice);
      expect(data.subtitle,  'New seasonal favourite ');
    });

    test('subtitle is stored exactly as provided', () {
      const data = TrendingRecipeData(
        recipe: Recipe(recipeId: 4, title: 'Butter Chicken '),
        trendType:  TrendType.trendingNow,
        subtitle:  '2.8k saves this week',
      );
      expect(data.subtitle, '2.8k saves this week');
    });

    test('recipe reference is preserved correctly', () {
      const recipe = Recipe(
        recipeId: 4,

        title: 'Butter Chicken',
        photoUrl: 'https://example.com/butter-chicken.jpg',
      );

      const data = TrendingRecipeData(
        recipe: recipe,
        trendType:  TrendType.trendingNow,
        subtitle:  '2.8k saves this week',
      );
      expect(data.recipe.title, 'Butter Chicken');
      expect(data.recipe.photoUrl, 'https://example.com/butter-chicken.jpg');
    });
  });
}