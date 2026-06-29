import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/discovery/models/discovery_category.dart';
import 'package:mealchemy/features/discovery/models/explore_item.dart';
import 'package:mealchemy/features/discovery/providers/discovery_provider.dart';
import 'package:mealchemy/features/discovery/repositories/discovery_repository.dart';
import 'package:mealchemy/features/discovery/screens/discovery_screen.dart';

class _FakeDiscoveryRepo implements DiscoveryRepository {
  @override
  Future<List<DiscoveryCategory>> getCategories() async => const [
        DiscoveryCategory(id: 1, name: 'Italian', imageUrl: ''),
        DiscoveryCategory(id: 2, name: 'Japanese', imageUrl: ''),
      ];

  @override
  Future<List<ExploreItem>> getExploreItems() async => const [
        ExploreItem(id: 1, title: 'Chef Special', imageUrl: '', isVideo: true),
        ExploreItem(id: 2, title: 'Beet Salad', imageUrl: '', matchPercent: 85),
        ExploreItem(id: 3, title: 'Glow Bowl', imageUrl: '', matchPercent: 88),
        ExploreItem(id: 4, title: 'Scallops', imageUrl: '', matchPercent: 90),
        ExploreItem(id: 5, title: 'Sirloin', imageUrl: '', matchPercent: 92),
      ];
}

class _ThrowingDiscoveryRepo implements DiscoveryRepository {
  @override
  Future<List<DiscoveryCategory>> getCategories() async =>
      throw Exception('network error');
  @override
  Future<List<ExploreItem>> getExploreItems() async =>
      throw Exception('network error');
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host(DiscoveryRepository repo) {
    final router = GoRouter(
      initialLocation: '/discovery',
      routes: [
        GoRoute(
          path: '/discovery',
          builder: (_, __) => const DiscoveryScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (_, __) => const Scaffold(body: Text('Dashboard')),
        ),
        GoRoute(
          path: '/vault',
          builder: (_, __) => const Scaffold(body: Text('Vault')),
        ),
        GoRoute(
          path: '/pantry',
          builder: (_, __) => const Scaffold(body: Text('Pantry')),
        ),
        GoRoute(
          path: '/preference',
          builder: (_, __) => const Scaffold(body: Text('Profile')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> pump(WidgetTester tester, DiscoveryRepository repo) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(host(repo));
    await tester.pumpAndSettle();
  }

  testWidgets('renders Discover header', (tester) async {
    await pump(tester, _FakeDiscoveryRepo());
    expect(find.text('Discover'), findsOneWidget);
  });

  testWidgets('renders filter bar options', (tester) async {
    await pump(tester, _FakeDiscoveryRepo());
    expect(find.text('Favourites'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Following'), findsOneWidget);
    expect(find.text('Trending'), findsOneWidget);
  });

  testWidgets('renders Popular Categories section header', (tester) async {
    await pump(tester, _FakeDiscoveryRepo());
    expect(find.text('Popular Categories'), findsOneWidget);
  });

  testWidgets('renders category names after data loads', (tester) async {
    await pump(tester, _FakeDiscoveryRepo());
    expect(find.text('Italian'), findsOneWidget);
    expect(find.text('Japanese'), findsOneWidget);
  });

  testWidgets('renders navbar', (tester) async {
    await pump(tester, _FakeDiscoveryRepo());
    expect(find.text('DISCOVER'), findsOneWidget);
  });

  testWidgets('does not crash when repository throws', (tester) async {
    await pump(tester, _ThrowingDiscoveryRepo());
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
