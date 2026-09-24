import 'package:dio/dio.dart';

import '../../recipe/models/recipe.dart';
import 'sizzles_repository.dart';

class ApiSizzlesRepository implements SizzlesRepository {
  ApiSizzlesRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Recipe>> getSizzles() async {
    try {
      final response = await _dio.get(
        '/recipes/community/sizzles',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      final items = response.data as List<dynamic>;
      return items
          .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        throw SizzlesLoadException(data['message'] as String);
      }
      throw const SizzlesLoadException(
        'Could not load Sizzles. Please try again.',
      );
    }
  }
}

class SizzlesLoadException implements Exception {
  const SizzlesLoadException(this.message);

  final String message;

  @override
  String toString() => message;
}
