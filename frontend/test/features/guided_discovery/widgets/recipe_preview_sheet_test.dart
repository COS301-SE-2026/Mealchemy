import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/guided_discovery/models/discovery_recipe.dart';
import 'package:mealchemy/features/guided_discovery/widgets/recipe_preview_sheet.dart';

void main() {
  setUpAll(() {
    //disable google fonts
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  //sample recipe to verify preview sheet
  final recipe = DiscoveryRecipe(
    id: 'test-recipe',
    title: 'Miso Salmon Rice Bowl',
    chefName: 'Chef Naomi',
    imageUrl: 'https://example.com/salmon.jpg',
    matchPercentage: 89,
    cookTimeMinutes: 32,
    calories: 510,
    proteinGrams: 36,
    carbsGrams: 42,
    fatGrams: 20,
    tags: const ['High Protein', 'Quick Meals'],
    ingredients: const ['Salmon', 'Rice', 'Miso glaze'],
    description: 'A balanced rice bowl with savoury miso salmon.',
    steps: const [
      'Cook the rice.',
      'Glaze the salmon.',
      'Assemble the bowl.',
    ],
    matchReason: 'You liked protein-forward recipes.',
  );

  //all recipe info displays
  testWidgets('RecipePreviewSheet renders recipe preview details', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RecipePreviewSheet(recipe: recipe),
          ),
        ),
      ),
    );

    await tester.pump();

    //recipe title, chef, description
    expect(find.text('Miso Salmon Rice Bowl'), findsOneWidget);
    expect(find.textContaining('Chef Naomi'), findsOneWidget);
    expect(
      find.text('A balanced rice bowl with savoury miso salmon.'),
      findsOneWidget,
    );
    expect(find.text('89% Match'), findsOneWidget);
    expect(find.text('32m'), findsOneWidget);
    expect(find.text('510'), findsOneWidget);
    expect(find.text('36g'), findsOneWidget);
    expect(find.text('High Protein'), findsOneWidget);
    expect(find.text('Quick Meals'), findsOneWidget);
    expect(find.text('Why this matches you'), findsOneWidget);
    expect(find.text('You liked protein-forward recipes.'), findsOneWidget);
    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('Salmon'), findsOneWidget);
    expect(find.text('Rice'), findsOneWidget);
    expect(find.text('Mock method'), findsOneWidget);
    expect(find.text('Cook the rice.'), findsOneWidget);
  });

    //action of close button
    testWidgets('RecipePreviewSheet action button closes preview', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => RecipePreviewSheet(recipe: recipe),
                  );
                },
                child: const Text('Open Preview'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open Preview'));
    await tester.pumpAndSettle();

    expect(find.text('Miso Salmon Rice Bowl'), findsOneWidget);

    final actionButton = find.text('Looks Good');

    await tester.ensureVisible(actionButton);
    await tester.pumpAndSettle();
    await tester.tap(actionButton);
    await tester.pumpAndSettle();

    expect(find.text('Miso Salmon Rice Bowl'), findsNothing);
  });
}