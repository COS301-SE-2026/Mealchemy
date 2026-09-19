import 'package:dio/dio.dart';
import '../models/preference_weights.dart';
import 'weights_repository.dart';

class ApiWeightsRepository implements WeightsRepository {
  ApiWeightsRepository(this._dio);

  final Dio _dio;
  static const _path = '/user/preferences/weights';

  @override
  Future<PreferenceWeights> getWeights() async {
    final response = await _dio.get<Map<String, dynamic>>(_path);
    return PreferenceWeights.fromJson(response.data!);
  }

  @override
  Future<PreferenceWeights> saveWeights(PreferenceWeights weights) async {
    final response = await _dio.put<Map<String, dynamic>>(
      _path,
      data: weights.toJson(),
    );
    return PreferenceWeights.fromJson(response.data!);
  }
}
