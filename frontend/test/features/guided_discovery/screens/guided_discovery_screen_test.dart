import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/guided_discovery/models/discovery_recipe.dart';
import 'package:mealchemy/features/guided_discovery/providers/guided_discovery_provider.dart';
import 'package:mealchemy/features/guided_discovery/repositories/guided_discovery_repository.dart';
import 'package:mealchemy/features/guided_discovery/screens/guided_discovery_screen.dart';

//mock repo with predictable recipe data
class _TestGuidedDiscoveryRepository implements GuidedDiscoveryRepository {
  @override
  Future<List<DiscoveryRecipe>> getDiscoveryRecipes() async {
    return [
      _createRecipe(
        id: 'recipe-one',
        title: 'Test Pasta',
      ),
      _createRecipe(
        id: 'recipe-two',
        title: 'Test Salmon',
      ),
    ];
  }
}

//mock repo to simulate API failure
class _FailingGuidedDiscoveryRepository
    implements GuidedDiscoveryRepository {
  @override
  Future<List<DiscoveryRecipe>> getDiscoveryRecipes() {
    throw Exception('Discovery failure');
  }
}

//creates reusable mock recipe
DiscoveryRecipe _createRecipe({
  required String id,
  required String title,
}) {
  return DiscoveryRecipe(
    id: id,
    title: title,
    chefName: 'Chef Test',
    imageUrl: 'https://example.com/recipe.jpg',
    matchPercentage: 90,
    cookTimeMinutes: 30,
    calories: 450,
    proteinGrams: 30,
    carbsGrams: 40,
    fatGrams: 15,
    tags: const ['Quick Meals', 'High Protein'],
    ingredients: const ['Ingredient one', 'Ingredient two'],
    description: 'A test recipe description.',
    steps: const ['Prepare ingredients.', 'Cook the recipe.'],
    matchReason: 'This recipe matches your test preferences.',
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host(GuidedDiscoveryRepository repository) {
    return ProviderScope(
      overrides: [
        guidedDiscoveryRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        home: Scaffold(body: GuidedDiscoveryScreen()),
      ),
    );
  }

  testWidgets('GuidedDiscoveryScreen renders discovery recipe', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(host(_TestGuidedDiscoveryRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Sizzles'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Quick Meals'), findsOneWidget);
    expect(find.text('Test Pasta'), findsOneWidget);
    expect(find.text('90% Match'), findsOneWidget);
    expect(find.text('View Full Recipe ->'), findsOneWidget);
  });

  testWidgets('GuidedDiscoveryScreen likes recipe using action button', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(host(_TestGuidedDiscoveryRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Test Pasta'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();

    expect(find.text('Test Pasta'), findsNothing);
    expect(find.text('Test Salmon'), findsOneWidget);
  });

  testWidgets('GuidedDiscoveryScreen skips recipe using action button', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(host(_TestGuidedDiscoveryRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Test Pasta'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Test Pasta'), findsNothing);
    expect(find.text('Test Salmon'), findsOneWidget);
  });

  testWidgets('GuidedDiscoveryScreen renders error state', (tester) async {
    await tester.pumpWidget(host(_FailingGuidedDiscoveryRepository()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Discovery failure'), findsOneWidget);
  });

  testWidgets('GuidedDiscoveryScreen likes recipe when swiped right', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(host(_TestGuidedDiscoveryRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Test Pasta'), findsOneWidget);

    await tester.drag(
      find.text('Test Pasta'),
      const Offset(250, 0),
    );

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('Test Pasta'), findsNothing);
    expect(find.text('Test Salmon'), findsOneWidget);
  });
}