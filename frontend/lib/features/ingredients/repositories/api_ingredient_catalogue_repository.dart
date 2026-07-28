import 'package:dio/dio.dart';
import '../models/ingredient_catalogue_item.dart';
import 'ingredient_catalogue_repository.dart';

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
}
