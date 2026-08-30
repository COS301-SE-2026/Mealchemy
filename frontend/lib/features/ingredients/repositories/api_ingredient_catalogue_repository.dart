import 'package:dio/dio.dart';
import '../models/ingredient_catalogue_item.dart';
import 'ingredient_catalogue_repository.dart';
import '../models/ingredient_category.dart';
import '../models/pending_external_ingredient.dart';

class ApiIngredientCatalogueRepository
    implements IngredientCatalogueRepository {
  final Dio _dio;
  ApiIngredientCatalogueRepository(this._dio);

  @override
  Future<List<IngredientCatalogueItem>> getAll() async {
    final response = await _dio.get('/api/ingredient-catalogue');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => IngredientCatalogueItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<IngredientCatalogueItem>> search(String query) async {
    final response = await _dio.get(
      '/api/ingredient-catalogue/search',
      queryParameters: {'q': query},
    );
    final data = response.data as List<dynamic>;
    return data
        .map((e) => IngredientCatalogueItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<IngredientCategory>> getCategories() async {
    final response = await _dio.get<List<dynamic>>('/api/categories');
    final data = response.data ?? [];

    return data
        .map(
          (category) => IngredientCategory.fromJson(
            category as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
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

      rethrow;
    }
  }
}
