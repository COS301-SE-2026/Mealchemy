import 'package:dio/dio.dart';

import '../models/ingredient_catalogue_item.dart';
import '../models/ingredient_category.dart';

//talks to the backend ingredient catalogue endpoints
class IngredientCatalogueRepository {
  IngredientCatalogueRepository(this._dio);

  final Dio _dio;

  Future<List<IngredientCatalogueItem>> getAllIngredients() async {
    final response = await _dio.get<List<dynamic>>('/api/ingredient-catalogue');
    return _itemsFromResponse(response.data);
  }

  Future<List<IngredientCatalogueItem>> searchIngredients(String query) async {
    final cleanedQuery = query.trim();

    if (cleanedQuery.isEmpty) {
      return [];
    }

    final response = await _dio.get<List<dynamic>>(
      '/api/ingredient-catalogue/search',
      queryParameters: {'q': cleanedQuery},
    );

    return _itemsFromResponse(response.data);
  }

  //loads the category choices used when USDA cannot determine a category
  Future<List<IngredientCategory>> getCategories() async {
    final response = await _dio.get<List<dynamic>>('/api/categories');
    final categories = response.data ?? [];

    return categories
        .map(
          (category) => IngredientCategory.fromJson(
            category as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  List<IngredientCatalogueItem> _itemsFromResponse(List<dynamic>? data) {
    final items = data ?? [];

    return items
        .map((item) => IngredientCatalogueItem.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }
}
