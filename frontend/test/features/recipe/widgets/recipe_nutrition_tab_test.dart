import 'dart:async';
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

class _ApiShapedNutritionRepository implements RecipeNutritionRepository {
  @override
  Future<RecipeNutrition> getRecipeNutrition(int recipeId) async {
    return RecipeNutrition.fromJson({
      'recipe_id': recipeId,
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
    });
  }
}

class _ControlledNutritionRepository implements RecipeNutritionRepository {
  final Completer<RecipeNutrition> completer = Completer<RecipeNutrition>();

  int requestCount = 0;

  @override
  Future<RecipeNutrition> getRecipeNutrition(int recipeId) {
    requestCount++;
    return completer.future;
  }
}

class _RetryNutritionRepository implements RecipeNutritionRepository {
  int requestCount = 0;

  @override
  Future<RecipeNutrition> getRecipeNutrition(int recipeId) async {
    requestCount++;

    if (requestCount == 1) {
      throw Exception('Temporary API failure');
    }

    return MockRecipeNutritionRepository().getRecipeNutrition(recipeId);
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpNutritionTab(
    WidgetTester tester, {
    RecipeNutritionRepository? repository,
    bool settle = true,
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

    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
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

  testWidgets('RecipeNutritionTab shows loading state while API request runs', (
    tester,
  ) async {
    final repository = _ControlledNutritionRepository();

    await pumpNutritionTab(
      tester,
      repository: repository,
      settle: false,
    );

    expect(repository.requestCount, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final nutrition =
        await MockRecipeNutritionRepository().getRecipeNutrition(42);

    repository.completer.complete(nutrition);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Nutritional Information'), findsOneWidget);
  });

  testWidgets('RecipeNutritionTab renders API-shaped calculator response', (
    tester,
  ) async {
    await pumpNutritionTab(
      tester,
      repository: _ApiShapedNutritionRepository(),
    );

    expect(find.text('4 servings per recipe'), findsOneWidget);
    expect(find.text('1167'), findsOneWidget);
    expect(find.text('33.5g'), findsOneWidget);
    expect(find.text('110.3g'), findsOneWidget);
    expect(find.text('69.1g'), findsOneWidget);

    await tester.tap(find.text('Per Serving'));
    await tester.pumpAndSettle();

    expect(find.text('291.8'), findsOneWidget);
    expect(find.text('8.4g'), findsOneWidget);
    expect(find.text('27.6g'), findsOneWidget);
    expect(find.text('17.3g'), findsOneWidget);

    final ingredientName = find.text('Chicken Breast Fillet');

    await tester.ensureVisible(ingredientName);
    await tester.pumpAndSettle();

    await tester.tap(ingredientName);
    await tester.pumpAndSettle();

    expect(find.text('26% of recipe calories'), findsOneWidget);
  });
  testWidgets('RecipeNutritionTab retries nutritional API request', (
    tester,
  ) async {
    final repository = _RetryNutritionRepository();

    await pumpNutritionTab(
      tester,
      repository: repository,
    );

    expect(repository.requestCount, 1);
    expect(
      find.text('Unable to load nutritional information.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(repository.requestCount, 2);
    expect(
      find.text('Unable to load nutritional information.'),
      findsNothing,
    );
    expect(find.text('Nutritional Information'), findsOneWidget);
  });
}
