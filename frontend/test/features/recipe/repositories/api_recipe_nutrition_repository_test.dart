import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/repositories/api_recipe_nutrition_repository.dart';

void main() {
  late Dio dio;
  late ApiRecipeNutritionRepository repository;
  late RequestOptions? lastRequest;

  setUp(() {
    dio = Dio();
    lastRequest = null;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          lastRequest = options;
          final statusCode = switch (options.path) {
            '/api/nutritional-calculator/400' => 400,
            '/api/nutritional-calculator/404' => 404,
            '/api/nutritional-calculator/500' => 500,
            _ => null,
          };

          if (statusCode != null) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: statusCode,
                  data: {
                    'message': statusCode == 404
                        ? 'Recipe not found or not accessible'
                        : 'Unable to calculate nutrition',
                  },
                ),
                type: DioExceptionType.badResponse,
              ),
            );
            return;
          }

          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'recipe_id': 42,
                'servings': 4,
                'totals': {
                  'calories_kcal': 1167.00,
                  'protein_g': 33.50,
                  'carbs_g': 110.30,
                  'fat_g': 69.10,
                  'fibre_g': 2.00,
                  'sodium_mg': 1804.00,
                },
                'per_serving': {
                  'calories_kcal': 291.75,
                  'protein_g': 8.38,
                  'carbs_g': 27.58,
                  'fat_g': 17.28,
                  'fibre_g': 0.50,
                  'sodium_mg': 451.00,
                },
                'ingredients': [
                  {
                    'ing_id': 101,
                    'name': 'Chicken Breast Fillet',
                    'quantity': 300,
                    'unit': 'g',
                    'calories_kcal': 303.00,
                    'protein_g': 69.00,
                    'carbs_g': 0.00,
                    'fat_g': 3.00,
                    'fibre_g': 0.00,
                    'sodium_mg': 210.00,
                  },
                ],
              },
            ),
          );
        },
      ),
    );

    repository = ApiRecipeNutritionRepository(dio);
  });

  Future<void> expectApiStatus({
    required int recipeId,
    required int expectedStatus,
  }) async {
    try {
      await repository.getRecipeNutrition(recipeId);
      fail('Expected DioException.');
    } on DioException catch (error) {
      expect(error.response?.statusCode, expectedStatus);
    }
  }

  test('getRecipeNutrition requests and maps calculator response', () async {
    final nutrition = await repository.getRecipeNutrition(42);

    expect(lastRequest?.method, 'GET');
    expect(
      lastRequest?.path,
      '/api/nutritional-calculator/42',
    );
    expect(lastRequest?.data, isNull);

    expect(nutrition.recipeId, 42);
    expect(nutrition.servings, 4);
    expect(nutrition.totals.caloriesKcal, 1167);
    expect(nutrition.perServing.caloriesKcal, 291.75);
    expect(nutrition.ingredients, hasLength(1));

    final ingredient = nutrition.ingredients.single;

    expect(ingredient.ingredientId, 101);
    expect(ingredient.name, 'Chicken Breast Fillet');
    expect(ingredient.quantity, 300);
    expect(ingredient.unit, 'g');
    expect(ingredient.values.caloriesKcal, 303);
    expect(
      ingredient.percentOfRecipeCalories,
      closeTo(25.96, 0.01),
    );
  });
  test('getRecipeNutrition preserves 400 response', () async {
    await expectApiStatus(
      recipeId: 400,
      expectedStatus: 400,
    );

    expect(
      lastRequest?.path,
      '/api/nutritional-calculator/400',
    );
  });

  test('getRecipeNutrition preserves inaccessible recipe 404 response',
      () async {
    await expectApiStatus(
      recipeId: 404,
      expectedStatus: 404,
    );

    expect(
      lastRequest?.path,
      '/api/nutritional-calculator/404',
    );
  });

  test('getRecipeNutrition preserves general API failure', () async {
    await expectApiStatus(
      recipeId: 500,
      expectedStatus: 500,
    );

    expect(
      lastRequest?.path,
      '/api/nutritional-calculator/500',
    );
  });
}
