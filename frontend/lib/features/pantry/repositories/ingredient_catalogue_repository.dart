import 'package:dio/dio.dart';

import '../models/ingredient_catalogue_item.dart';
import '../models/ingredient_category.dart';
import '../models/pending_external_ingredient.dart';

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

  //imports USDA result into local catalogue
  Future<IngredientCatalogueItem> importExternalIngredient({
    required String sourceId,
    int? categoryId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/ingredient-catalogue/add-external',
        data: {
          'source_id': sourceId,
          'category_id': categoryId,
        },
      );

      final data = response.data;

      if (data == null) {
        throw const FormatException(
          'External ingredient import returned no data.',
        );
      }

      return IngredientCatalogueItem.fromJson(data);
    } on DioException catch (error) {
      final response = error.response;

      if (response?.statusCode == 422 && response?.data is Map) {
        final pendingData = Map<String, dynamic>.from(
          response!.data as Map,
        );

        throw ExternalIngredientCategoryRequiredException(
          PendingExternalIngredient.fromJson(pendingData),
        );
      }

      //anything other than expected 422 remains a normal API error
      rethrow;
    }
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

//signals to UI that import must be retried after choosing category
class ExternalIngredientCategoryRequiredException implements Exception {
  const ExternalIngredientCategoryRequiredException(this.ingredient);

  final PendingExternalIngredient ingredient;
}
