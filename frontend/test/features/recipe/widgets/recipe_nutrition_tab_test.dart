import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mealchemy/features/recipe/providers/recipe_nutrition_provider.dart';
import 'package:mealchemy/features/recipe/repositories/mock_recipe_nutrition_repository.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_nutrition_tab.dart';
import 'package:mealchemy/features/recipe/models/recipe_nutrition.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_nutrition_repository.dart';

class _FailingNutritionRepository implements RecipeNutritionRepository {
  @override
  Future<RecipeNutrition> getRecipeNutrition(int recipeId) async {
    throw Exception('Nutrition unavailable.');
  }
}

class _NotFoundNutritionRepository implements RecipeNutritionRepository {
  @override
  Future<RecipeNutrition> getRecipeNutrition(int recipeId) async {
    final requestOptions = RequestOptions(
      path: '/api/nutritional-calculator/$recipeId',
    );

    throw DioException(
      requestOptions: requestOptions,
      response: Response(
        requestOptions: requestOptions,
        statusCode: 404,
        data: {
          'message': 'Recipe not found or not accessible',
        },
      ),
      type: DioExceptionType.badResponse,
    );
  }
}

class _EmptyNutritionRepository implements RecipeNutritionRepository {
  @override
  Future<RecipeNutrition> getRecipeNutrition(int recipeId) async {
    return RecipeNutrition(
      recipeId: recipeId,
      servings: 1,
      totals: const NutritionValues(
        caloriesKcal: 0,
        proteinG: 0,
        carbsG: 0,
        fatG: 0,
        fibreG: 0,
        sodiumMg: 0,
      ),
      perServing: const NutritionValues(
        caloriesKcal: 0,
        proteinG: 0,
        carbsG: 0,
        fatG: 0,
        fibreG: 0,
        sodiumMg: 0,
      ),
      ingredients: const [],
    );
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpNutritionTab(
    WidgetTester tester, {
    RecipeNutritionRepository? repository,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recipeNutritionRepositoryProvider.overrideWithValue(
            repository ?? MockRecipeNutritionRepository(),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: RecipeNutritionTab(
              recipeId: 42,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('RecipeNutritionTab displays whole recipe nutrition', (
    tester,
  ) async {
    await pumpNutritionTab(tester);

    expect(find.text('Nutritional Information'), findsOneWidget);
    expect(find.text('4 servings per recipe'), findsOneWidget);
    expect(find.text('1167'), findsOneWidget);
    expect(find.text('Total recipe calories · kcal'), findsOneWidget);

    expect(find.text('33.5g'), findsOneWidget);
    expect(find.text('110.3g'), findsOneWidget);
    expect(find.text('69.1g'), findsOneWidget);

    expect(find.text('2 g'), findsOneWidget);
    expect(find.text('1804 mg'), findsOneWidget);
  });

  testWidgets('RecipeNutritionTab switches to per-serving values', (
    tester,
  ) async {
    await pumpNutritionTab(tester);

    await tester.tap(find.text('Per Serving'));
    await tester.pumpAndSettle();

    expect(find.text('291.8'), findsOneWidget);
    expect(find.text('Calories per serving · kcal'), findsOneWidget);

    expect(find.text('8.4g'), findsOneWidget);
    expect(find.text('27.6g'), findsOneWidget);
    expect(find.text('17.3g'), findsOneWidget);

    expect(find.text('0.5 g'), findsOneWidget);
    expect(find.text('451 mg'), findsOneWidget);
  });

  testWidgets('RecipeNutritionTab expands ingredient nutrition', (
    tester,
  ) async {
    await pumpNutritionTab(tester);

    await tester.ensureVisible(
      find.text('Chicken Breast Fillet'),
    );
    await tester.tap(find.text('Chicken Breast Fillet'));
    await tester.pumpAndSettle();

    expect(find.text('69 g'), findsOneWidget);
    expect(find.text('0 g'), findsNWidgets(2));
    expect(find.text('3 g'), findsOneWidget);
    expect(find.text('210 mg'), findsOneWidget);
    expect(find.text('26% of recipe calories'), findsOneWidget);
  });

  testWidgets('RecipeNutritionTab displays empty ingredient state', (
    tester,
  ) async {
    await pumpNutritionTab(
      tester,
      repository: _EmptyNutritionRepository(),
    );

    expect(
      find.text('No ingredient nutrition is available for this recipe.'),
      findsOneWidget,
    );
    expect(find.text('0 ingredients'), findsOneWidget);
  });

  testWidgets('RecipeNutritionTab displays repository failure', (
    tester,
  ) async {
    await pumpNutritionTab(
      tester,
      repository: _FailingNutritionRepository(),
    );

    expect(
      find.text('Unable to load nutritional information.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
  });
  testWidgets('RecipeNutritionTab displays unavailable state for 404', (
    tester,
  ) async {
    await pumpNutritionTab(
      tester,
      repository: _NotFoundNutritionRepository(),
    );

    expect(
      find.text(
        'Nutritional information is not available for this recipe.',
      ),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
    expect(
      find.text('Unable to load nutritional information.'),
      findsNothing,
    );
  });
}
