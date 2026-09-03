import 'package:mealchemy/features/dashboard/models/trending_recipe_data.dart';
import 'dashboard_repository.dart';

//implement all methods using Dio at integration
class ApiDashboardRepository implements DashboardRepository {
  @override
  Future<String> getDisplayName() {
    throw UnimplementedError('Dashboard API integration not implemented yet.');
  }

  @override
  Future<int> getPantryItemCount() {
    throw UnimplementedError('Dashboard API integration not implemented yet.');
  }

  @override
  Future<int> getSmartSuggestionItemsAway() {
    throw UnimplementedError('Dashboard API integration not implemented yet.');
  }

  @override
  Future<int> getSmartSuggestionRecipeCount() {
    throw UnimplementedError('Dashboard API integration not implemented yet.');
  }


  @override
  Future<List<TrendingRecipeData>> getTrendingRecipes() {
    throw UnimplementedError('Dashboard API integration not implemented yet.');
  }
}