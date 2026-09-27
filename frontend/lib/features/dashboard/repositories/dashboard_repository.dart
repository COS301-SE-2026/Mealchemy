

abstract class DashboardRepository {
  Future<String> getDisplayName();
  Future<int> getPantryItemCount();

  Future<int>  getSmartSuggestionItemsAway();
  Future<int> getSmartSuggestionRecipeCount();
  
}