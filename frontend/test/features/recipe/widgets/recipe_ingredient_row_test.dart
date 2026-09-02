import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_ingredient_row.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  // baseServings matches the recipe size and the provider is left unseeded,
  // so the scale factor is 1.0 and amounts render unscaled.
  Widget host(Widget child) => ProviderScope(
        child: MaterialApp(home: Scaffold(body: child)),
      );

  testWidgets('RecipeIngredientRow renders name, integer quantity and unit', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const RecipeIngredientRow(
          ingredient: RecipeIngredient(
            ingId: 1,
            name: 'Arborio rice',
            quantity: 320,
            unit: 'g',
            sortOrder: 1,
          ),
          recipeId: 1,
          baseServings: 4,
        ),
      ),
    );

    expect(find.text('Arborio rice'), findsOneWidget);
    expect(find.text('320 g'), findsOneWidget);
  });

  testWidgets('RecipeIngredientRow renders bare quantity when unit is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const RecipeIngredientRow(
          ingredient: RecipeIngredient(
            ingId: 2,
            name: 'Garlic cloves',
            quantity: 3,
            sortOrder: 2,
          ),
          recipeId: 1,
          baseServings: 4,
        ),
      ),
    );

    expect(find.text('Garlic cloves'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('RecipeIngredientRow hides quantity when null', (tester) async {
    await tester.pumpWidget(
      host(
        const RecipeIngredientRow(
          ingredient: RecipeIngredient(
            ingId: 3,
            name: 'Salt to taste',
            sortOrder: 3,
          ),
          recipeId: 1,
          baseServings: 4,
        ),
      ),
    );

    expect(find.text('Salt to taste'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^\d')), findsNothing);
  });

  testWidgets('RecipeIngredientRow formats decimal quantity with unit', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const RecipeIngredientRow(
          ingredient: RecipeIngredient(
            ingId: 4,
            name: 'Vodka',
            quantity: 0.5,
            unit: 'cup',
            sortOrder: 4,
          ),
          recipeId: 1,
          baseServings: 4,
        ),
      ),
    );

    expect(find.text('0.5 cup'), findsOneWidget);
  });

  testWidgets('RecipeIngredientRow scales quantity with chosen servings', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          servingsProvider(1).overrideWith((ref) => 8),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: RecipeIngredientRow(
              ingredient: RecipeIngredient(
                ingId: 5,
                name: 'Arborio rice',
                quantity: 320,
                unit: 'g',
                sortOrder: 1,
              ),
              recipeId: 1,
              baseServings: 4,
            ),
          ),
        ),
      ),
    );

    // 8 servings from a base of 4 doubles the amount.
    expect(find.text('640 g'), findsOneWidget);
  });
}