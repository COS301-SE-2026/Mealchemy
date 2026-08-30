import '../models/ingredient_catalogue_item.dart';
import '../models/ingredient_category.dart';

abstract class IngredientCatalogueRepository {
  //GET /api/ingredient-catalogue
  Future<List<IngredientCatalogueItem>> getAll();

  //GET /api/ingredient-catalogue/search?q=
  Future<List<IngredientCatalogueItem>> search(String query);

  //GET /api/categories
  Future<List<IngredientCategory>> getCategories();

  //POST /api/ingredient-catalogue/add-external
  Future<IngredientCatalogueItem> importExternalIngredient({
    required String sourceId,
    int? categoryId,
  });
}
