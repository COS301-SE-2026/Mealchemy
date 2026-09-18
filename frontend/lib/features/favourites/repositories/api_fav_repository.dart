import 'package:dio/dio.dart';

import '../models/favourite.dart';
import 'fav_repository.dart';

class ApiFavRepository implements FavRepository {
  ApiFavRepository(this._dio);

  final Dio _dio;

  static const _base = '/api/favourites';

  @override
  Future<List<Favourite>> getFavs() async {
    final response = await _dio.get<List<dynamic>>(_base);
    final data = response.data ?? [];

    return data
        .map((json) => Favourite.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Favourite> addFav({required int recipeId}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _base,
      data: {'recipe_id': recipeId},

    );
    return Favourite.fromJson(response.data!);
  }

  @override
  Future<void> removeFav(int recipeId) async {
    await _dio.delete('$_base/$recipeId');
  }
}