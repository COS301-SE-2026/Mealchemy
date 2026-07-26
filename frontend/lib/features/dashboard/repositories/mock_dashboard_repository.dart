import 'package:mealchemy/features/dashboard/models/dashboard_recipe_card_data.dart';
import 'package:mealchemy/features/dashboard/models/trending_recipe_data.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'dashboard_repository.dart';

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<String> getDisplayName() async {
    return 'Mutombo';
  }

  @override
  Future<int> getPantryItemCount() async {
    return 42;
  }

  @override
  Future<int> getSmartSuggestionItemsAway() async {
    return 3;
  }

  @override
  Future<int> getSmartSuggestionRecipeCount() async {
    return 10;
  }

  @override
  Future<List<DashboardRecipeCardData>> getRecommendedRecipes() async {
    return const [
      DashboardRecipeCardData(
        recipe: Recipe(
          recipeId: 1,
          title:  'Saffron-Infused Risotto',
          prepTimeMins: 15,
          cookingTimeMins:  30,
          photoUrl:  'https://images.unsplash.com/photo-1673439782150-8e14d276b5d4?w=400',
        ),
        matchPercent: 92,
         tag:  'HIGH PROTEIN',
        rating: 4.9,
      ),
      DashboardRecipeCardData(
        recipe: Recipe(
          recipeId: 2,

          title: 'Braised  Short Rib Pappardelle ',
          prepTimeMins: 20,
          cookingTimeMins: 180,

          photoUrl:  'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400',
        ),
        matchPercent: 85,
        tag: 'HIGH PROTEIN',
        rating: 4.7,
      ),
       DashboardRecipeCardData(
        recipe: Recipe(
          recipeId: 3,

          title: ' Avocado & Kale Superbowl',
          prepTimeMins: 15,
          cookingTimeMins: 25,
          photoUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
        ),
        matchPercent: 80,
        tag: 'PLANT BASED',
        rating: 4.5,
      ),
       DashboardRecipeCardData(
        recipe: Recipe(
          recipeId: 4,
           title: 'Butter Chicken ',
          prepTimeMins:  20,
          cookingTimeMins: 35,
          photoUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400',
        ),
         matchPercent: 76,

        tag: 'COMFORT FOOD ',
        rating: 4.8,
      ),
      DashboardRecipeCardData(
        recipe: Recipe(
           recipeId: 5,
          title: 'Dark Chocolate & Gold Ganache ',
           prepTimeMins: 30,
          cookingTimeMins: 20,
          photoUrl: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400',
        ),
        matchPercent: 70,
         tag: 'INDULGENT ',
        rating: 4.6,
      ),
      DashboardRecipeCardData(
        recipe: Recipe(
          recipeId: 6,
          title: ' Miso Glazed Salmon',
          prepTimeMins: 10,
           cookingTimeMins: 15,
          photoUrl: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400',
        ),
        matchPercent: 68,
        tag: ' HIGH PROTEIN',
        rating: 4.4,
      ),
    ];
  }

  @override
  Future<List<TrendingRecipeData>> getTrendingRecipes() async {
    return const [
      TrendingRecipeData(
        recipe: Recipe(
          recipeId: 3,
          title: 'Avocado & Kale Superbowl ',
          photoUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
        ),
        trendType: TrendType.trendingNow,
         subtitle: '4.2k saves this week',
      ),
      TrendingRecipeData(
        recipe: Recipe(
          recipeId: 5,
          title: 'Dark Chocolate & Gold Ganache',
          photoUrl: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400',
        ),
        trendType: TrendType.editorsChoice,
        subtitle: 'New seasonal favourite',
      ),
      TrendingRecipeData(
        recipe: Recipe(
          recipeId: 4,
           title: 'Butter Chicken ',
          photoUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400',
        ),

        trendType: TrendType.trendingNow,
        
        subtitle: '2.8k saves this week ',
      ),
    ];
  }
}