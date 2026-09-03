import 'package:mealchemy/features/dashboard/models/trending_recipe_data.dart';

abstract class DashboardRepository {
  Future<String> getDisplayName();
  Future<int> getPantryItemCount();

  Future<int>  getSmartSuggestionItemsAway();
  Future<int> getSmartSuggestionRecipeCount();
  Future<List< TrendingRecipeData>>  getTrendingRecipes();
  
}