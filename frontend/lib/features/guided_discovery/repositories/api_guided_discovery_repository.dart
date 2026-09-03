import 'package:dio/dio.dart';

import '../models/recommendation.dart';
import '../models/swipe.dart';
import 'guided_discovery_repository.dart';

class ApiGuidedDiscoveryRepository implements GuidedDiscoveryRepository {
  final Dio _dio;

  ApiGuidedDiscoveryRepository(this._dio);

  @override
  Future<List<Recommendation>> getRecommendations({
    int batchSize = 10,
    List<int> excludeRecipeIds = const [],
  }) async {
    try {
      final response = await _dio.get(
        '/discovery/recommendations',
        queryParameters: {
          'batchSize': batchSize,
          if (excludeRecipeIds.isNotEmpty) 'excludeRecipeIds': excludeRecipeIds,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      final items = (response.data['recommendations'] as List<dynamic>?) ?? [];

      if (items.isEmpty) {
        throw const EmptyRecommendationPool();
      }

      return items
          .map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw const EmptyRecommendationPool();
      }
      throw _messageFrom(e);
    }
  }

  @override
  Future<SwipeResponse> recordSwipe(SwipeRequest request) async {
    try {
      final response = await _dio.post(
        '/discovery/swipes',
        data: request.toJson(),
      );
      return SwipeResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _messageFrom(e);
    }
  }

  String _messageFrom(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return 'Something went wrong. Please try again.';
  }
}
