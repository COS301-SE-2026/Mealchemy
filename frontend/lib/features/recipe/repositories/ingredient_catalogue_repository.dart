import '../models/ingredient_catalogue_item.dart';

abstract class IngredientCatalogueRepository {
  //GET /api/ingredient-catalogue
  Future<List<IngredientCatalogueItem>> getAll();

  //GET /api/ingredient-catalogue/search?q=
  Future<List<IngredientCatalogueItem>> search(String query);
}