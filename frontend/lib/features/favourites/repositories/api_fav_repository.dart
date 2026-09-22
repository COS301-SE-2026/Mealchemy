import 'package:dio/dio.dart';

import '../models/favourite.dart';
import 'fav_repository.dart';

class ApiFavRepository implements FavRepository {
  ApiFavRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Favourite>> getFavs() async {
    final response = await _dio.get<Map<String, dynamic>>('/discovery/liked');
    final data = response.data?['liked_recipes'] as List<dynamic>? ?? [];
    return data
        .map((json) => Favourite.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> removeFav(int recipeId) async {
    await _dio.delete('/discovery/liked/$recipeId');
  }
}