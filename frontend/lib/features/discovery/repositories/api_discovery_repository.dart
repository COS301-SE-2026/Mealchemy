import 'package:dio/dio.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/discovery/repositories/discovery_repository.dart';

class ApiDiscoveryRepository implements DiscoveryRepository {
  final Dio _dio;
  ApiDiscoveryRepository(this._dio);

  //all community-published recipes
  @override
  Future<List<Recipe>> getPublishedRecipes() async {
    final response = await _dio.get('/recipes/community');
    final data = response.data as List<dynamic>;
    return data.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
  }

//cuisine values from flavour profile options, used as category filters
  @override
  Future<List<String>> getCuisineTypes() async {
    final response = await _dio.get('/flavourprofileoptions/all');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => (e as Map<String, dynamic>)['value'] as String)
        .toList();
  }
}
