import 'package:mealchemy/features/dashboard/models/dashboard_recipe_card_data.dart';
import 'package:mealchemy/features/dashboard/models/trending_recipe_data.dart';

abstract class DashboardRepository {
  Future<String> getDisplayName();
  Future<int> getPantryItemCount();

  Future<int>  getSmartSuggestionItemsAway();
  Future<int> getSmartSuggestionRecipeCount();
  Future<List<DashboardRecipeCardData >>  getRecommendedRecipes();
  Future<List< TrendingRecipeData>>  getTrendingRecipes();
  
}