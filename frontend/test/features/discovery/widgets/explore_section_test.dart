import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/discovery/models/discovery_category.dart';
import 'package:mealchemy/features/discovery/models/explore_item.dart';
import 'package:mealchemy/features/discovery/providers/discovery_provider.dart';
import 'package:mealchemy/features/discovery/repositories/discovery_repository.dart';
import 'package:mealchemy/features/discovery/widgets/explore_section.dart';

class _FakeDiscoveryRepo implements DiscoveryRepository {
  @override
  Future<List<DiscoveryCategory>> getCategories() async => const [
        DiscoveryCategory(id: 1, name: 'Italian', imageUrl: ''),
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

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget host(Widget child) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(
            body: SingleChildScrollView(child: child),
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(_FakeDiscoveryRepo()),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(host(child));
  }

  group('ExploreSection', () {
    testWidgets('renders nothing before data loads', (tester) async {
      await pump(tester, const ExploreSection());
      await tester.pump();
      expect(find.text('Explore'), findsNothing);
    });

    testWidgets('renders Explore header after data loads', (tester) async {
      await pump(tester, const ExploreSection());

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ExploreSection)),
      );
      await container.read(discoveryProvider.notifier).loadDiscovery();
      await tester.pumpAndSettle();

      expect(
        find.textContaining(RegExp(r'Recipes|Explore')),
        findsOneWidget,
      );
    });

    testWidgets('renders recipe titles after data loads', (tester) async {
      await pump(tester, const ExploreSection());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ExploreSection)),
      );
      await container.read(discoveryProvider.notifier).loadDiscovery();
      await tester.pumpAndSettle();

      expect(find.text('Beet Salad'), findsOneWidget);
      expect(find.text('Sirloin'), findsOneWidget);
    });

    testWidgets('renders VIEW ALL trailing label', (tester) async {
      await pump(tester, const ExploreSection());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ExploreSection)),
      );
      await container.read(discoveryProvider.notifier).loadDiscovery();
      await tester.pumpAndSettle();
      expect(find.text('VIEW ALL'), findsOneWidget);
    });
  });
}
