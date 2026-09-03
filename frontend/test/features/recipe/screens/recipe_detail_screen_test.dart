import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';
import 'package:mealchemy/features/recipe/screens/recipe_detail_screen.dart';
import 'package:mealchemy/features/recipe/providers/recipe_nutrition_provider.dart';
import 'package:mealchemy/features/recipe/repositories/mock_recipe_nutrition_repository.dart';

const _fixture = Recipe(
  recipeId: 1,
  title: 'Saffron-Infused Risotto',
  cuisineType: 'italian',
  prepTimeMins: 15,
  cookingTimeMins: 30,
  servingSize: 4,
  ingredients: [
    RecipeIngredient(
      ingId: 16,
      name: 'Arborio Rice',
      quantity: 320,
      unit: 'g',
      sortOrder: 2,
    ),
    RecipeIngredient(
      ingId: 17,
      name: 'Saffron',
      quantity: 1,
      unit: 'pinch',
      sortOrder: 1,
    ),
  ],
  steps: [
    RecipeStep(stepNr: 1, content: 'Warm the stock.'),
    RecipeStep(stepNr: 2, content: 'Toast the rice.'),
  ],
);

Widget _host(Widget child, List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: child),
  );
}

void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1080, 2400);
    view.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('shows a loading indicator while the recipe resolves',
      (tester) async {
    final completer = Completer<Recipe>();
    await tester.pumpWidget(_host(
      const RecipeDetailScreen(recipeId: 1),
      [recipeDetailProvider(1).overrideWith((ref) => completer.future)],
    ));

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(_fixture);
    await tester.pumpAndSettle();
  });

  testWidgets('renders title and cook/prep stats once loaded', (tester) async {
    await tester.pumpWidget(_host(
      const RecipeDetailScreen(recipeId: 1),
      [recipeDetailProvider(1).overrideWith((ref) async => _fixture)],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Saffron-Infused Risotto'), findsWidgets);
    expect(find.text('30m'), findsOneWidget); // cook time
    expect(find.text('15m'), findsOneWidget); // prep time
  });

  testWidgets('renders ingredient names from the recipe', (tester) async {
    await tester.pumpWidget(_host(
      const RecipeDetailScreen(recipeId: 1),
      [recipeDetailProvider(1).overrideWith((ref) async => _fixture)],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Arborio Rice'), findsOneWidget);
  });

  testWidgets('falls back to "Ingredient #<ingId>" when name is null',
      (tester) async {
    const noName = Recipe(
      recipeId: 2,
      title: 'Nameless',
      prepTimeMins: 5,
      cookingTimeMins: 5,
      servingSize: 2,
      ingredients: [
        RecipeIngredient(
          ingId: 42,
          quantity: 100,
          unit: 'g',
          sortOrder: 1,
        ),
      ],
      steps: [],
    );

    await tester.pumpWidget(_host(
      const RecipeDetailScreen(recipeId: 2),
      [recipeDetailProvider(2).overrideWith((ref) async => noName)],
    ));
    await tester.pump(); // let the future resolve
    await tester.pump(const Duration(milliseconds: 300)); // let tabs settle
    expect(tester.takeException(), isNull);
    expect(find.text('Ingredient #42'), findsOneWidget);
  });

  testWidgets('shows an error state when the recipe fails to load',
      (tester) async {
    await tester.pumpWidget(_host(
      const RecipeDetailScreen(recipeId: 1),
      [
        recipeDetailProvider(1)
            .overrideWith((ref) async => throw Exception('boom')),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Unable to load recipe.'), findsOneWidget);
  });

  testWidgets('shows the save (bookmark) action in the hero', (tester) async {
    await tester.pumpWidget(_host(
      const RecipeDetailScreen(recipeId: 1),
      [recipeDetailProvider(1).overrideWith((ref) async => _fixture)],
    ));
    await tester.pumpAndSettle();

    // hero's share button became a save/bookmark button
    expect(find.byIcon(Icons.bookmark_add_outlined), findsOneWidget);
  });

  testWidgets('opens mocked nutrition data in the Nutrition tab', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const RecipeDetailScreen(recipeId: 1),
        [
          recipeDetailProvider(1).overrideWith(
            (ref) async => _fixture,
          ),
          recipeNutritionRepositoryProvider.overrideWithValue(
            MockRecipeNutritionRepository(),
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Nutrition'));
    await tester.pumpAndSettle();

    expect(find.text('Nutritional Information'), findsOneWidget);
    expect(find.text('4 servings per recipe'), findsOneWidget);
    expect(find.text('1167'), findsOneWidget);
    expect(find.text('Chicken Breast Fillet'), findsOneWidget);
  });

  testWidgets('tapping the servings stepper scales ingredient amounts',
      (tester) async {
    await tester.pumpWidget(_host(
      const RecipeDetailScreen(recipeId: 1),
      [recipeDetailProvider(1).overrideWith((ref) async => _fixture)],
    ));
    await tester.pumpAndSettle();

    expect(find.text('320 g'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    expect(find.text('400 g'), findsOneWidget);
    expect(find.text('320 g'), findsNothing);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(find.text('320 g'), findsOneWidget);
  });
}
