import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/guided_discovery/models/recommendation.dart';
import 'package:mealchemy/features/guided_discovery/models/signal_scores.dart';
import 'package:mealchemy/features/guided_discovery/widgets/recipe_preview_sheet.dart';

void main() {
  setUpAll(() {
    //disable google fonts
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const signals = SignalScores(
    pantryMatch: 0.9,
    cuisine: 0.8,
    nutrition: 0.5,
    freshness: 0.3,
    novelty: 1.0,
  );

  final rec = Recommendation(
    recipeId: 7,
    cuisineType: 'JAPANESE',
    score: 0.89,
    scoreBreakdown: signals,
    pantryGapCount: 2,
    missingIngredients: const ['white miso', 'sesame seeds'],
    recipe: const Recipe(
      recipeId: 7,
      title: 'Miso Salmon Rice Bowl',
      description: 'A balanced rice bowl with savoury miso salmon.',
      cuisineType: 'JAPANESE',
      prepTimeMins: 10,
      cookingTimeMins: 22,
      servingSize: 2,
      photoUrl: 'https://example.com/salmon.jpg',
      isCommunityPublished: true,
    ),
  );

  testWidgets('renders preview details for a recommendation', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecipePreviewSheet(recommendation: rec)),
      ),
    );
    await tester.pump();

    expect(find.text('Miso Salmon Rice Bowl'), findsOneWidget);
    expect(find.text('Japanese'), findsOneWidget); 
    expect( find.text('A balanced rice bowl with savoury miso salmon.'),
            findsOneWidget,);
    expect(find.text('89% Match'), findsOneWidget);
    expect(find.text('10m'), findsOneWidget); 
    expect(find.text('22m'), findsOneWidget); 
    expect(find.text('32m'), findsOneWidget); 
    expect(find.text('Why this matches you'), findsOneWidget);
    expect(find.text("You're missing 2 items"), findsOneWidget);
    expect(find.text('white miso'), findsOneWidget);
    expect(find.text('sesame seeds'), findsOneWidget);
    expect(find.text('Looks Good'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });

  testWidgets('closes the sheet when Close is tapped', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => RecipePreviewSheet(recommendation: rec),
              ),
              child: const Text('Open Preview'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Preview'));
    await tester.pumpAndSettle();
    expect(find.text('Miso Salmon Rice Bowl'), findsOneWidget);
    final closeBtn = find.text('Close');
    await tester.ensureVisible(closeBtn);
    await tester.pumpAndSettle();
    await tester.tap(closeBtn);
    await tester.pumpAndSettle();

    expect(find.text('Miso Salmon Rice Bowl'), findsNothing);
  });
}