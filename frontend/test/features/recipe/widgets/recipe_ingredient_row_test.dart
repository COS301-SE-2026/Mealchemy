import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_ingredient_row.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('RecipeIngredientRow renders name, integer quantity and unit', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const RecipeIngredientRow(
          ingredient: RecipeIngredient(
            ingredientId: 1,
            recipeId: 1,
            nameRaw: 'Arborio rice',
            quantity: 320,
            unit: 'g',
            sortOrder: 1,
          ),
        ),
      ),
    );

    expect(find.text('Arborio rice'), findsOneWidget);
    //integer quantity strips trailing zeros
    expect(find.text('320 g'), findsOneWidget);
    expect(find.text('IN PANTRY'), findsNothing);
  });

  testWidgets('RecipeIngredientRow shows IN PANTRY badge when inPantry is true', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const RecipeIngredientRow(
          ingredient: RecipeIngredient(
            ingredientId: 2,
            recipeId: 1,
            nameRaw: 'Garlic cloves',
            quantity: 3,
            sortOrder: 2,
            inPantry: true,
          ),
        ),
      ),
    );

    expect(find.text('Garlic cloves'), findsOneWidget);
    //null unit drops the unit suffix
    expect(find.text('3'), findsOneWidget);
    expect(find.text('IN PANTRY'), findsOneWidget);
  });

  testWidgets('RecipeIngredientRow hides quantity when null', (tester) async {
    await tester.pumpWidget(
      host(
        const RecipeIngredientRow(
          ingredient: RecipeIngredient(
            ingredientId: 3,
            recipeId: 1,
            nameRaw: 'Salt to taste',
            sortOrder: 3,
          ),
        ),
      ),
    );

    expect(find.text('Salt to taste'), findsOneWidget);
    //regex for a string first charachter is a digit. 
    expect(find.textContaining(RegExp(r'^\d')), findsNothing);
  });

  testWidgets('RecipeIngredientRow formats decimal quantity with unit', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const RecipeIngredientRow(
          ingredient: RecipeIngredient(
            ingredientId: 4,
            recipeId: 1,
            nameRaw: 'Vodka',
            quantity: 0.5,
            unit: 'cup',
            sortOrder: 4,
          ),
        ),
      ),
    );

    expect(find.text('0.5 cup'), findsOneWidget);
  });

  testWidgets('RecipeIngredientRow does not show IN PANTRY when inPantry is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const RecipeIngredientRow(
          ingredient: RecipeIngredient(
            ingredientId: 5,
            recipeId: 1,
            nameRaw: 'Saffron threads',
            quantity: 1,
            unit: 'pinch',
            sortOrder: 5,
          ),
        ),
      ),
    );

    expect(find.text('IN PANTRY'), findsNothing);
  });
}
