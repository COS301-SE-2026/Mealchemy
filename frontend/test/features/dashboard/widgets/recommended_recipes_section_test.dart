import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/dashboard/models/trending_recipe_data.dart';
import 'package:mealchemy/features/dashboard/providers/dashboard_provider.dart';
import 'package:mealchemy/features/dashboard/repositories/dashboard_repository.dart';
import 'package:mealchemy/features/dashboard/widgets/recommended_recipes_section.dart';
import 'package:mealchemy/features/guided_discovery/models/recommendation.dart';
import 'package:mealchemy/features/guided_discovery/models/signal_scores.dart';
import 'package:mealchemy/features/guided_discovery/models/swipe.dart';
import 'package:mealchemy/features/guided_discovery/providers/guided_discovery_provider.dart';
import 'package:mealchemy/features/guided_discovery/repositories/guided_discovery_repository.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

const _signals = SignalScores(
  pantryMatch: 0.9,
  cuisine: 0.8,
  nutrition: 0.5,
  freshness: 0.3,
  novelty: 1.0,
);

Recommendation _rec(int id, String title, String cuisine, double score) =>
    Recommendation(
      recipeId: id,
      cuisineType: cuisine,
      score: score,
      scoreBreakdown: _signals,
      pantryGapCount: 0,
      missingIngredients: const [],
      recipe: Recipe(recipeId: id, title: title, cuisineType: cuisine),
    );

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
  Future<List<TrendingRecipeData>> getTrendingRecipes() async => [];
}

class _FakeGuidedDiscoveryRepo implements GuidedDiscoveryRepository {
  @override
  Future<List<Recommendation>> getRecommendations({
    int batchSize = 10,
    List<int> excludeRecipeIds = const [],
  }) async =>
      [
        _rec(1, 'Saffron Risotto', 'ITALIAN', 0.92),
        _rec(2, 'Butter Chicken', 'INDIAN', 0.85),
      ];

  @override
  Future<SwipeResponse> recordSwipe(SwipeRequest request) async =>
      throw UnimplementedError();
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
          builder: (_, __) =>
              Scaffold(body: SingleChildScrollView(child: child)),
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
        guidedDiscoveryRepositoryProvider
            .overrideWithValue(_FakeGuidedDiscoveryRepo()),
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

  });
}