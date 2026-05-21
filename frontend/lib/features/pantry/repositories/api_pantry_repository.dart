import '../models/pantry_ingredient.dart';
import '../models/pantry_summary.dart';
import 'pantry_repository.dart';

//backend pantry data (future)
class ApiPantryRepository implements PantryRepository {
  @override
  Future<PantrySummary> getPantrySummary() {
    throw UnimplementedError(
      'Pantry API integration has not been implemented yet.',
    );
  }

  @override
  Future<List<PantryFilter>> getPantryFilters() {
    throw UnimplementedError(
      'Pantry API integration has not been implemented yet.',
    );
  }

  @override
  Future<List<PantryIngredient>> getPantryIngredients() {
    throw UnimplementedError(
      'Pantry API integration has not been implemented yet.',
    );
  }

  @override
  Future<List<String>> getIngredientCategories() {
    throw UnimplementedError(
      'Pantry API integration has not been implemented yet.',
    );
  }
}