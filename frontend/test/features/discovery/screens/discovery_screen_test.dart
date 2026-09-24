import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/discovery/providers/discovery_provider.dart';
import 'package:mealchemy/features/discovery/repositories/discovery_repository.dart';
import 'package:mealchemy/features/discovery/screens/discovery_screen.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

// The screen calls loadDiscovery() in initState, so these fakes drive the real
// load path: getPublishedRecipes() + getCuisineTypes().
class _FakeDiscoveryRepo implements DiscoveryRepository {
  @override
  Future<List<Recipe>> getPublishedRecipes() async => const [
        Recipe(recipeId: 1, title: 'Beet Salad', cuisineType: 'italian'),
        Recipe(recipeId: 2, title: 'Ramen', cuisineType: 'japanese'),
      ];

  @override
  Future<List<String>> getCuisineTypes() async => const ['italian', 'japanese'];

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}

class _ThrowingDiscoveryRepo implements DiscoveryRepository {
  @override
  Future<List<Recipe>> getPublishedRecipes() async =>
      throw Exception('network error');

  @override
  Future<List<String>> getCuisineTypes() async =>
      throw Exception('network error');

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget host(DiscoveryRepository repo) {
    final router = GoRouter(
      initialLocation: '/discovery',
      routes: [
        GoRoute(
          path: '/discovery',
          builder: (_, __) => const Scaffold(body: DiscoveryScreen()),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (_, __) => const Scaffold(body: Text('Dashboard')),
        ),
        GoRoute(
          path: '/vault',
          builder: (_, __) => const Scaffold(body: Text('Vault')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [discoveryRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> pump(
    WidgetTester tester,
    DiscoveryRepository repo, {
    Size size = const Size(1080, 2400),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(host(repo));
    await tester.pumpAndSettle();
  }

  group('DiscoveryScreen', () {
    testWidgets('renders the search bar', (tester) async {
      await pump(tester, _FakeDiscoveryRepo());
      expect(find.text('Search recipes...'), findsOneWidget);
    });

    testWidgets('renders formatted cuisine chips after data loads',
        (tester) async {
      await pump(tester, _FakeDiscoveryRepo());
      // getCuisineTypes returns lowercase; the chip formats to title case.
      expect(find.text('Italian'), findsOneWidget);
      expect(find.text('Japanese'), findsOneWidget);
    });

    testWidgets('renders the Explore section with published recipes',
        (tester) async {
      await pump(tester, _FakeDiscoveryRepo());
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Beet Salad'), findsOneWidget);
    });

    testWidgets('typing filters the explore grid', (tester) async {
      await pump(tester, _FakeDiscoveryRepo());

      await tester.enterText(find.byType(TextField).first, 'ramen');
      await tester.pumpAndSettle();

      expect(find.text('Ramen'), findsOneWidget);
      expect(find.text('Beet Salad'), findsNothing);
    });

    testWidgets('shows an empty message when the search matches nothing',
        (tester) async {
      await pump(tester, _FakeDiscoveryRepo());

      await tester.enterText(find.byType(TextField).first, 'zzz');
      await tester.pumpAndSettle();

      expect(find.text('No recipes found for "zzz".'), findsOneWidget);
    });

    testWidgets('does not crash when the repository throws', (tester) async {
      await pump(tester, _ThrowingDiscoveryRepo());
      // The load error is caught in the notifier; the screen still builds.
      expect(find.byType(DiscoveryScreen), findsOneWidget);
      expect(find.text('Search recipes...'), findsOneWidget);
    });

    testWidgets('lays out without overflow on a small screen', (tester) async {
      await pump(tester, _FakeDiscoveryRepo(), size: const Size(360, 640));
      expect(tester.takeException(), isNull);
    });
  });
}