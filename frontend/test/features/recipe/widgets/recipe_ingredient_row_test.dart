import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_ingredient_row.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

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
        ),
      ),
    );

    expect(find.text('Arborio rice'), findsOneWidget);
    //integer quantity strips trailing zeros
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
        ),
      ),
    );

    expect(find.text('Garlic cloves'), findsOneWidget);
    //null unit drops the unit suffix
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
        ),
      ),
    );

    expect(find.text('Salt to taste'), findsOneWidget);
    //regex for a string whose first character is a digit
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
        ),
      ),
    );

    expect(find.text('0.5 cup'), findsOneWidget);
  });
}
