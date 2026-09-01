import 'package:dio/dio.dart';

import '../models/recipe_nutrition.dart';
import 'recipe_nutrition_repository.dart';

//loads the complete nutritional calculator response for one recipe
class ApiRecipeNutritionRepository implements RecipeNutritionRepository {
  ApiRecipeNutritionRepository(this._dio);

  final Dio _dio;

  @override
  Future<RecipeNutrition> getRecipeNutrition(int recipeId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/nutritional-calculator/$recipeId',
    );

    final data = response.data;

    if (data == null) {
      throw const FormatException(
        'Nutritional calculator returned no data.',
      );
    }

    return RecipeNutrition.fromJson(data);
  }
}
