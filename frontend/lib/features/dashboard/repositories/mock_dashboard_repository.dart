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

}