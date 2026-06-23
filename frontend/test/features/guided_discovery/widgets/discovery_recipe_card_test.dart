import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/guided_discovery/models/discovery_recipe.dart';
import 'package:mealchemy/features/guided_discovery/widgets/discovery_recipe_card.dart';

void main() {
  //disable google fonts during tests
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  //sample recipe for recipe card functionality
  final recipe = DiscoveryRecipe(
    id: 'test-recipe',
    title: 'Braised Short Rib Pappardelle',
    chefName: 'Chef Isabella',
    imageUrl: 'https://example.com/pasta.jpg',
    matchPercentage: 92,
    cookTimeMinutes: 45,
    calories: 420,
    proteinGrams: 12,
    carbsGrams: 54,
    fatGrams: 18,
    tags: const ['Quick Meals', 'High Protein'],
    ingredients: const ['Pappardelle', 'Short rib', 'Tomato'],
    description: 'A rich pasta dish with slow-cooked short rib.',
    steps: const ['Cook the pasta.', 'Serve with sauce.'],
    matchReason: 'You liked hearty pasta dishes.',
  );

  //tests that recipe card displays info
  testWidgets('DiscoveryRecipeCard renders recipe details', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 560,
            child: DiscoveryRecipeCard(
              recipe: recipe,
              currentIndex: 0,
              totalRecipes: 3,
              onViewRecipe: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    //verify match percentage
    expect(find.text('92% Match'), findsOneWidget);
    //recipe info
    expect(find.text('Braised Short Rib Pappardelle'), findsOneWidget);
    expect(find.textContaining('Chef Isabella'), findsOneWidget);
    expect(find.text('420'), findsOneWidget);
    expect(find.text('12g'), findsOneWidget);
    expect(find.text('54g'), findsOneWidget);
    expect(find.text('18g'), findsOneWidget);
    expect(find.text('45m'), findsOneWidget);
    expect(find.text('View Full Recipe ->'), findsOneWidget);
  });

  //tests that tapping recipe action link
  testWidgets('DiscoveryRecipeCard calls onViewRecipe when link is tapped', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 560,
            child: DiscoveryRecipeCard(
              recipe: recipe,
              currentIndex: 0,
              totalRecipes: 3,
              onViewRecipe: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    await tester.tap(find.text('View Full Recipe ->'));

    expect(tapped, isTrue);
  });
}