import 'package:dio/dio.dart';

import '../models/favourite.dart';
import 'fav_repository.dart';

class ApiFavRepository implements FavRepository {
  ApiFavRepository(this._dio);

  final Dio _dio;

  static const _neutralScores = {
    'pantry_match': 0.5,
    'cuisine': 0.5,
    'nutrition': 0.5,
    'freshness': 0.5,
    'novelty': 0.5,
  };

  @override
  Future<List<Favourite>> getFavs() async {
    final response = await _dio.get<Map<String, dynamic>>('/discovery/liked');
    final data = response.data?['liked_recipes'] as List<dynamic>? ?? [];
    return data
        .map((json) => Favourite.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  //unlike is a new append-only swipe, there is no delete endpoint
  @override
  Future<void> removeFav(int recipeId, {required String cuisineValue}) async {
    await _dio.post('/discovery/swipes', data: {
      'recipe_id': recipeId,
      'cuisine_value': cuisineValue,
      'action': 'UNLIKED',
      'signal_scores': _neutralScores,
    });
  }
}