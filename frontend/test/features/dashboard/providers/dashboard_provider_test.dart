import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/dashboard/models/trending_recipe_data.dart';
import 'package:mealchemy/features/dashboard/providers/dashboard_provider.dart';
import 'package:mealchemy/features/dashboard/repositories/dashboard_repository.dart';
import 'package:mealchemy/features/dashboard/repositories/mock_dashboard_repository.dart';
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

Recommendation _rec(int id, String title) => Recommendation(
      recipeId: id,
      cuisineType: 'ITALIAN',
      score: 0.9,
      scoreBreakdown: _signals,
      pantryGapCount: 0,
      missingIngredients: const [],
      recipe: Recipe(recipeId: id, title: title),
    );


class _FakeGuidedDiscoveryRepo implements GuidedDiscoveryRepository {
  @override
  Future<List<Recommendation>> getRecommendations({
    int batchSize = 10,
    List<int> excludeRecipeIds = const [],
  }) async =>
      [_rec(1, 'Saffron Risotto'), _rec(2, 'Butter Chicken')];

  @override
  Future<SwipeResponse> recordSwipe(SwipeRequest request) async =>
      SwipeResponse(
        swipeId: 1,
        recipeId: request.recipeId,
        cuisineValue: request.cuisineValue,
        action: request.action,
        swipedAt: DateTime.now(),
      );
}

// Guided discovery returns nothing (empty deck)
class _EmptyGuidedDiscoveryRepo implements GuidedDiscoveryRepository {
  @override
  Future<List<Recommendation>> getRecommendations({
    int batchSize = 10,
    List<int> excludeRecipeIds = const [],
  }) async =>
      const [];

  @override
  Future<SwipeResponse> recordSwipe(SwipeRequest request) async =>
      throw UnimplementedError();
}

// Fake dashboard repo that throws on every call to test stat load failure.
class _ThrowingDashboardRepo implements DashboardRepository {
  @override
  Future<String> getDisplayName() async => throw Exception('network error');
  @override
  Future<int> getPantryItemCount() async => throw Exception('network error');
  @override
  Future<int> getSmartSuggestionItemsAway() async =>
      throw Exception('network error');
  @override
  Future<int> getSmartSuggestionRecipeCount() async =>
      throw Exception('network error');
  @override
  Future<List<TrendingRecipeData>> getTrendingRecipes() async =>
      throw Exception('network error');
}

ProviderContainer _container({
  DashboardRepository? dashboard,
  GuidedDiscoveryRepository? discovery,
}) =>
    ProviderContainer(
      overrides: [
        dashboardRepositoryProvider
            .overrideWithValue(dashboard ?? MockDashboardRepository()),
        guidedDiscoveryRepositoryProvider
            .overrideWithValue(discovery ?? _FakeGuidedDiscoveryRepo()),
      ],
    );

void main() {
  group('DashboardState defaults', () {
    test('starts with isLoading false', () {
      const state = DashboardState();
      expect(state.isLoading, false);
    });
    test('starts with empty displayName', () {
      const state = DashboardState();
      expect(state.displayName, isEmpty);
    });
    test('starts with pantryItemCount of zero', () {
      const state = DashboardState();
      expect(state.pantryItemCount, 0);
    });
    test('starts with empty recommendedRecipes', () {
      const state = DashboardState();
      expect(state.recommendedRecipes, isEmpty);
    });
    test('starts with empty trendingRecipes', () {
      const state = DashboardState();
      expect(state.trendingRecipes, isEmpty);
    });
    test('starts with null errorMessage', () {
      const state = DashboardState();
      expect(state.errorMessage, isNull);
    });
  });

  group('DashboardState.copyWith', () {
    test('overrides only isLoading', () {
      const state = DashboardState();
      final next = state.copyWith(isLoading: true);
      expect(next.isLoading, true);
      expect(next.displayName, isEmpty);
    });
    test('clears errorMessage when not provided', () {
      const state = DashboardState(errorMessage: 'old error');
      final next = state.copyWith(isLoading: true);
      expect(next.errorMessage, isNull);
    });
    test('preserves recommendedRecipes when not overridden', () {
      final state = DashboardState(recommendedRecipes: [_rec(1, 'Test')]);
      final next = state.copyWith(isLoading: true);
      expect(next.recommendedRecipes, hasLength(1));
    });
  });

  group('DashboardNotifier.loadDashboard', () {
    test('populates stats, recommendations and trending on success', () async {
      final container = _container();
      addTearDown(container.dispose);

      await container.read(dashboardProvider.notifier).loadDashboard();
      final state = container.read(dashboardProvider);

      expect(state.isLoading, false);
      expect(state.displayName, isNotEmpty);
      expect(state.pantryItemCount, greaterThan(0));
      expect(state.recommendedRecipes, isNotEmpty);
      expect(state.trendingRecipes, isNotEmpty);
      expect(state.errorMessage, isNull);
    });

    test('recommendations come from guided discovery, not the dashboard repo',
        () async {
      final container = _container();
      addTearDown(container.dispose);

      await container.read(dashboardProvider.notifier).loadDashboard();
      final titles = container
          .read(dashboardProvider)
          .recommendedRecipes
          .map((r) => r.recipe.title);

      expect(titles, containsAll(['Saffron Risotto', 'Butter Chicken']));
    });

    test('still surfaces recommendations when the dashboard repo throws',
        () async {
      final container = _container(dashboard: _ThrowingDashboardRepo());
      addTearDown(container.dispose);

      await container.read(dashboardProvider.notifier).loadDashboard();
      final state = container.read(dashboardProvider);

      // Stats failed, but recommendations from guided discovery still loaded.
      expect(state.isLoading, false);
      expect(state.recommendedRecipes, isNotEmpty);
      expect(state.trendingRecipes, isEmpty);
    });

    test('keeps recommendations empty when guided discovery is empty',
        () async {
      final container = _container(discovery: _EmptyGuidedDiscoveryRepo());
      addTearDown(container.dispose);

      await container.read(dashboardProvider.notifier).loadDashboard();
      expect(container.read(dashboardProvider).recommendedRecipes, isEmpty);
    });
  });
}