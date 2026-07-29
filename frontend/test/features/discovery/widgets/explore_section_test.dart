import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/discovery/providers/discovery_provider.dart';
import 'package:mealchemy/features/discovery/repositories/discovery_repository.dart';
import 'package:mealchemy/features/discovery/widgets/explore_section.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

class _UnusedDiscoveryRepo implements DiscoveryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}

class _FakeDiscoveryNotifier extends DiscoveryNotifier {
  _FakeDiscoveryNotifier(DiscoveryState initial)
      : super(_UnusedDiscoveryRepo()) {
    state = initial;
  }
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  const recipes = [
    Recipe(recipeId: 1, title: 'Beet Salad', cuisineType: 'italian'),
    Recipe(recipeId: 2, title: 'Glow Bowl', cuisineType: 'italian'),
    Recipe(recipeId: 3, title: 'Scallops', cuisineType: 'italian'),
    Recipe(recipeId: 4, title: 'Sirloin', cuisineType: 'italian'),
  ];

  Widget host(DiscoveryState state) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            body: SingleChildScrollView(child: ExploreSection()),
          ),
        ),
        GoRoute(
          path: '/recipe/:id',
          builder: (_, __) => const Scaffold(body: Text('Recipe Detail')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        discoveryProvider.overrideWith((ref) => _FakeDiscoveryNotifier(state)),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> pump(WidgetTester tester, DiscoveryState state) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(host(state));
    await tester.pumpAndSettle();
  }

  group('ExploreSection', () {
    testWidgets('shows the empty state when there are no recipes',
        (tester) async {
      await pump(tester, const DiscoveryState(recipes: []));

      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('No published recipes yet.'), findsOneWidget);
    });

    testWidgets('renders the Explore header and recipe titles', (tester) async {
      await pump(tester, const DiscoveryState(recipes: recipes));

      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Beet Salad'), findsOneWidget);
      expect(find.text('Sirloin'), findsOneWidget);
    });

    testWidgets('adds the cuisine to the header when one is selected',
        (tester) async {
      await pump(
        tester,
        const DiscoveryState(recipes: recipes, selectedCuisine: 'italian'),
      );
      expect(find.text('Explore Italian'), findsOneWidget);
      expect(find.text('Beet Salad'), findsOneWidget);
    });

    testWidgets('filters out recipes that do not match the selected cuisine',
        (tester) async {
      await pump(
        tester,
        const DiscoveryState(
          recipes: [
            Recipe(recipeId: 1, title: 'Beet Salad', cuisineType: 'italian'),
            Recipe(recipeId: 2, title: 'Ramen', cuisineType: 'japanese'),
          ],
          selectedCuisine: 'italian',
        ),
      );

      expect(find.text('Beet Salad'), findsOneWidget);
      expect(find.text('Ramen'), findsNothing); 
    });
    
    testWidgets('tapping a cell navigates to the recipe detail',
        (tester) async {
      await pump(tester, const DiscoveryState(recipes: recipes));

      await tester.tap(find.text('Beet Salad'));
      await tester.pumpAndSettle();

      expect(find.text('Recipe Detail'), findsOneWidget);
    });
  });
}