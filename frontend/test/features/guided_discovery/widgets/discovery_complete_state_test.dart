import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/guided_discovery/models/discovery_recipe.dart';
import 'package:mealchemy/features/guided_discovery/widgets/discovery_complete_state.dart';

void main() {
  setUpAll(() {
    //disable google fonts
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  //sample recipe
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
    steps: const ['Cook the rice.', 'Glaze the salmon.'],
    matchReason: 'You liked protein-forward recipes.',
  );

  //summary, taste signals, recommendation
  testWidgets('DiscoveryCompleteState renders recommendation summary', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiscoveryCompleteState(
            likedCount: 2,
            dislikedCount: 1,
            tasteSignals: const ['High Protein', 'Quick Meals'],
            recommendedRecipe: recipe,
            onReset: () {},
          ),
        ),
      ),
    );

    await tester.pump();

    //summary info
    expect(find.text('Taste profile ready'), findsOneWidget);
    expect(
      find.text(
        'Your mock recommendations were shaped by 2 likes and 1 skips.',
      ),
      findsOneWidget,
    );
    expect(find.text('Taste signals'), findsOneWidget);
    expect(find.text('High Protein'), findsOneWidget);
    expect(find.text('Quick Meals'), findsOneWidget);
    expect(find.text('Recommended next'), findsOneWidget);
    expect(find.text('Miso Salmon Rice Bowl'), findsOneWidget);
    expect(find.text('89% match • 32m'), findsOneWidget);
    expect(find.text('Start Again'), findsOneWidget);
  });

  testWidgets('DiscoveryCompleteState displays default taste signals', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiscoveryCompleteState(
            likedCount: 0,
            dislikedCount: 3,
            tasteSignals: const [],
            recommendedRecipe: null,
            onReset: () {},
          ),
        ),
      ),
    );

    //taste preferences
    expect(find.text('Balanced'), findsOneWidget);
    expect(find.text('Flexible'), findsOneWidget);
    expect(find.text('Exploratory'), findsOneWidget);
    expect(find.text('Recommended next'), findsNothing);
  });

  testWidgets('DiscoveryCompleteState calls onReset when tapped', (
    tester,
  ) async {
    var resetCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiscoveryCompleteState(
            likedCount: 1,
            dislikedCount: 2,
            tasteSignals: const ['Vegetarian'],
            recommendedRecipe: null,
            onReset: () => resetCalled = true,
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Start Again'));
    await tester.tap(find.text('Start Again'));

    expect(resetCalled, isTrue);
  });
}