import '../models/pantry_ingredient.dart';
import '../models/pantry_summary.dart';

//uses mock/API data
abstract class PantryRepository {
  Future<PantrySummary> getPantrySummary();

  Future<List<PantryFilter>> getPantryFilters();

  Future<List<PantryIngredient>> getPantryIngredients();

  Future<List<String>> getIngredientCategories();

  //adds one catalogue ingredient to the logged-in user's pantry
  Future<PantryIngredient> addPantryIngredient({
    required int ingId,
    required String quantity,
    required String unit,
  });
}
