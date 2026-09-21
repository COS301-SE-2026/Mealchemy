import 'package:dio/dio.dart';

class RecipeReportReason {
  const RecipeReportReason({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  factory RecipeReportReason.fromJson(Map<String, dynamic> json) {
    final value = json['value'] as String;
    final label = json['label'] as String;

    if (value.trim().isEmpty || label.trim().isEmpty) {
      throw const FormatException('Invalid report reason.');
    }

    return RecipeReportReason(value: value, label: label);
  }
}

abstract class RecipeReportRepository {
  Future<List<RecipeReportReason>> getReasons();

  Future<void> reportRecipe({
    required int recipeId,
    required String reasonValue,
  });
}

class ApiRecipeReportRepository implements RecipeReportRepository {
  ApiRecipeReportRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<RecipeReportReason>> getReasons() async {
    final response = await _dio.get<dynamic>('/flagreasons/all');
    final data = response.data as List<dynamic>;

    final reasons = data
        .map(
          (item) => RecipeReportReason.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();

    if (reasons.map((reason) => reason.value).toSet().length !=
        reasons.length) {
      throw const FormatException('Duplicate report reason values.');
    }

    return List.unmodifiable(reasons);
  }

  @override
  Future<void> reportRecipe({
    required int recipeId,
    required String reasonValue,
  }) async {
    if (recipeId <= 0 || reasonValue.trim().isEmpty) {
      throw ArgumentError('A recipe and report reason are required.');
    }

    await _dio.post<dynamic>(
      '/recipes/$recipeId/flag',
      data: {'reason_value': reasonValue},
    );
  }
}
