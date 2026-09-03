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