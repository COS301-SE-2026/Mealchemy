import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/discovery/models/discovery_category.dart';
import 'package:mealchemy/features/discovery/models/explore_item.dart';
import 'package:mealchemy/features/discovery/providers/discovery_provider.dart';
import 'package:mealchemy/features/discovery/repositories/discovery_repository.dart';
import 'package:mealchemy/features/discovery/widgets/popular_categories_section.dart';

class _FakeDiscoveryRepo implements DiscoveryRepository {
  @override
  Future<List<DiscoveryCategory>> getCategories() async => const [
        DiscoveryCategory(id: 1, name: 'Italian',  imageUrl: ''),
        DiscoveryCategory(id: 2, name: 'Japanese', imageUrl: ''),
        DiscoveryCategory(id: 3, name: 'Indian',   imageUrl: ''),
      ];

  @override
  Future<List<ExploreItem>> getExploreItems() async => [];
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

  group('PopularCategoriesSection', () {
    testWidgets('renders section header', (tester) async {
      await pump(tester, const PopularCategoriesSection());
      await tester.pump();

      expect(find.text('Popular Categories'), findsOneWidget);
    });

    testWidgets('renders category names after data loads', (tester) async {
      await pump(tester, const PopularCategoriesSection());

      final container = ProviderScope.containerOf(
        tester.element(find.byType(PopularCategoriesSection)),
      );
      await container.read(discoveryProvider.notifier).loadDiscovery();
      await tester.pumpAndSettle();

      expect(find.text('Italian'),  findsOneWidget);
      expect(find.text('Japanese'), findsOneWidget);
      expect(find.text('Indian'),   findsOneWidget);
    });

    testWidgets('first category is selected by default', (tester) async {
      await pump(tester, const PopularCategoriesSection());

      final container = ProviderScope.containerOf(
        tester.element(find.byType(PopularCategoriesSection)),
      );
      await container.read(discoveryProvider.notifier).loadDiscovery();
      await tester.pumpAndSettle();

      expect(container.read(discoveryProvider).selectedCategoryId, 1);
    });

    testWidgets('tapping a category updates selectedCategoryId', (tester) async {
      await pump(tester, const PopularCategoriesSection());

      final container = ProviderScope.containerOf(
        tester.element(find.byType(PopularCategoriesSection)),
      );
      await container.read(discoveryProvider.notifier).loadDiscovery();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Japanese'));
      await tester.pump();

      expect(container.read(discoveryProvider).selectedCategoryId, 2);
    });
  });
}