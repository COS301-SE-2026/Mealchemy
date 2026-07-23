import 'package:dio/dio.dart';

import '../models/ingredient_catalogue_item.dart';

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

  List<IngredientCatalogueItem> _itemsFromResponse(List<dynamic>? data) {
    final items = data ?? [];

    return items
        .map((item) => IngredientCatalogueItem.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }
}
