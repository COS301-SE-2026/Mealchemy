import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/guided_discovery/models/recommendation.dart';
import 'package:mealchemy/features/guided_discovery/models/signal_scores.dart';
import 'package:mealchemy/features/guided_discovery/widgets/discovery_recipe_card.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const signals = SignalScores(
    pantryMatch: 0.9,
    cuisine: 0.8,
    nutrition: 0.5,
    freshness: 0.3,
    novelty: 1.0,
  );

  final withGap = Recommendation(
    recipeId: 7,
    cuisineType: 'ITALIAN',
    score: 0.92,
    scoreBreakdown: signals,
    pantryGapCount: 1,
    missingIngredients: const ['parmesan'],
    recipe: const Recipe(
      recipeId: 7,
      title: 'Braised Short Rib Pappardelle',
      cuisineType: 'ITALIAN',
      prepTimeMins: 15,
      cookingTimeMins: 30,
      servingSize: 4,
      photoUrl: 'https://example.com/pasta.jpg',
      isCommunityPublished: true,
    ),
  );

  Widget host(Recommendation rec, {VoidCallback? onView}) => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 560,
            child: DiscoveryRecipeCard(
              recommendation: rec,
              currentIndex: 0,
              totalRecipes: 3,
              onViewRecipe: onView ?? () {},
            ),
          ),
        ),
      );

  testWidgets('renders match, title, cuisine, time and the view link', (
    tester,
  ) async {
    await tester.pumpWidget(host(withGap));
    await tester.pump();

    expect(find.text('92% Match'), findsOneWidget);
    expect(find.text('Braised Short Rib Pappardelle'), findsOneWidget);
    expect(find.text('Italian'), findsOneWidget); 
    expect(find.text('45m'), findsOneWidget); 
    expect(find.text('View Full Recipe ->'), findsOneWidget);
  });

  testWidgets('shows the missing-ingredients pantry hint', (tester) async {
    await tester.pumpWidget(host(withGap));
    await tester.pump();
    expect(find.text('Missing: parmesan'), findsOneWidget);
  });

  testWidgets('shows "You have everything" when there is no pantry gap', (
    tester,
  ) async {
    final noGap = Recommendation(
      recipeId: 8,
      cuisineType: 'GREEK',
      score: 0.7,
      scoreBreakdown: signals,
      pantryGapCount: 0,
      missingIngredients: const [],
      recipe: const Recipe(
        recipeId: 8,
        title: 'Greek Salad',
        cuisineType: 'GREEK',
        prepTimeMins: 10,
        cookingTimeMins: 0,
        servingSize: 2,
      ),
    );

    await tester.pumpWidget(host(noGap));
    await tester.pump();

    expect(find.text('You have everything'), findsOneWidget);
  });

  testWidgets('calls onViewRecipe when the link is tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(host(withGap, onView: () => tapped = true));
    await tester.pump();

    await tester.tap(find.text('View Full Recipe ->'));
    expect(tapped, isTrue);
  });
}