import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/dashboard/models/dashboard_recipe_card_data.dart';
import 'package:mealchemy/features/dashboard/models/trending_recipe_data.dart';
import 'package:mealchemy/features/dashboard/providers/dashboard_provider.dart';
import 'package:mealchemy/features/dashboard/repositories/dashboard_repository.dart';
import 'package:mealchemy/features/dashboard/widgets/recommended_recipes_section.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

class _FakeDashboardRepo implements DashboardRepository {
  @override
  Future<String> getDisplayName() async => 'Mutombo';
  @override
  Future<int> getPantryItemCount() async => 42;
  @override
  Future<int> getSmartSuggestionItemsAway() async => 3;
  @override
  Future<int> getSmartSuggestionRecipeCount() async => 10;

  @override
  Future<List<DashboardRecipeCardData>> getRecommendedRecipes() async {
    return const [
      DashboardRecipeCardData(
        recipe: Recipe(recipeId: 1, title: 'Saffron Risotto'),
        matchPercent: 92,
        tag: 'HIGH PROTEIN',
        rating: 4.9,
      ),
      DashboardRecipeCardData(
        recipe: Recipe(recipeId: 2, title: 'Butter Chicken'),
        matchPercent: 85,

        tag:  'COMFORT FOOD',
        rating: 4.7,
      ),
    ];
  }

  @override
  Future<List<TrendingRecipeData>> getTrendingRecipes() async => [];
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
          builder: (_, __) => Scaffold(body: SingleChildScrollView(child: child)),
        ),
        GoRoute(
          path: '/recipe/:id',
          builder: (_, __) => const Scaffold(body: Text('Recipe Detail')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(_FakeDashboardRepo()),
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

  group('RecommendedRecipesSection', () {
    testWidgets('renders section header', (tester) async {
      await pump(tester, const RecommendedRecipesSection());
      await tester.pump();
      expect(find.text('Recommended for You'), findsOneWidget);
    });

    testWidgets('renders View all trailing label', (tester) async {
      await pump(tester, const RecommendedRecipesSection());
      await tester.pump();

      expect(find.text('View all'), findsOneWidget);
    });

    testWidgets('renders recipe titles after data loads', (tester) async {
      await pump(tester, const RecommendedRecipesSection());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(RecommendedRecipesSection)),
      );
      await container.read(dashboardProvider.notifier).loadDashboard();
      await tester.pumpAndSettle();

      expect(find.text('Saffron Risotto'), findsOneWidget);
      expect(find.text('Butter Chicken'), findsOneWidget);
    });

    testWidgets('renders recipe tags after data loads', (tester) async {
      await pump(tester, const RecommendedRecipesSection());

      final container = ProviderScope.containerOf(
        tester.element(find.byType(RecommendedRecipesSection)),
      );
      await container.read(dashboardProvider.notifier).loadDashboard();
      await tester.pumpAndSettle();

      expect(find.text('HIGH PROTEIN'), findsOneWidget);
      expect(find.text('COMFORT FOOD'), findsOneWidget);
    });
  });
}