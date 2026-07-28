import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/dashboard/models/dashboard_recipe_card_data.dart';
import 'package:mealchemy/features/dashboard/models/trending_recipe_data.dart';
import 'package:mealchemy/features/dashboard/providers/dashboard_provider.dart';
import 'package:mealchemy/features/dashboard/repositories/dashboard_repository.dart';
import 'package:mealchemy/features/dashboard/repositories/mock_dashboard_repository.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

//Fake repository that throws on every call to test error handling
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
  Future<List<DashboardRecipeCardData>> getRecommendedRecipes() async =>
      throw Exception('network error');
  @override
  Future<List<TrendingRecipeData>> getTrendingRecipes() async =>
      throw Exception('network error');
}

void main() {
  group('dashboardRepositoryProvider', () {
    test('returns MockDashboardRepository while AppConfig.useMockData is true',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final repository = container.read(dashboardRepositoryProvider);
      expect(repository, isA<MockDashboardRepository>());
    });
  });

  group('DashboardState defaults', () {
    test('starts with isLoading  false ', () {
      const state = DashboardState();
      expect(state.isLoading, false);
    });
    test(' starts with empt displayName', () {
      const state = DashboardState();
      expect(state.displayName, isEmpty);
    });

    test('starts with  pantryItemCount of zero ', () {
      const state = DashboardState();
      expect(state.pantryItemCount, 0);
    });

    test('starts with  smartSuggestionItemsAway of zero', () {
      const state = DashboardState();
      expect(state.smartSuggestionItemsAway, 0);
    });
    test('starts with  smartSuggestioRecipeCount of zero', () {
      const state = DashboardState();
      expect(state.smartSuggestionRecipeCount, 0);
    });
    test('starts with empty recommendedRecipes', () {
      const state = DashboardState();
      expect(state.recommendedRecipes, isEmpty);
    });
    test('starts with empty treningRecipes ', () {
      const state = DashboardState();
      expect(state.trendingRecipes, isEmpty);
    });
    test('starts with null errorMessage ', () {
      const state = DashboardState();
      expect(state.errorMessage, isNull);
    });
  });
  group('DashboardState.copyWith ', () {
    test(' overrides only isLoading', () {
      const state = DashboardState();
      final next = state.copyWith(isLoading: true);

      expect(next.isLoading, true);
      expect(next.displayName, isEmpty);
      expect(next.pantryItemCount, 0);
    });
    test('overrides only displayName', () {
      const state = DashboardState();
      final next = state.copyWith(displayName: 'Paul');
      expect(next.displayName, 'Paul');
      expect(next.isLoading, false);
    });
    test(' overrides only pantryItemCount ', () {
      const state = DashboardState();
      final next = state.copyWith(pantryItemCount: 42);
      expect(next.pantryItemCount, 42);
      expect(next.isLoading, false);
    });

    test('clears error Message when not provided ', () {
      const state = DashboardState(errorMessage: 'old error');
      final next = state.copyWith(isLoading: true);

      expect(next.errorMessage, isNull);
    });

    test('preserves existing lists when not overridden ', () {
      final recipe = const DashboardRecipeCardData(
        recipe: Recipe(recipeId: 1, title: 'Test'),
        matchPercent: 90,
        tag: 'HIGH PROTEIN',
        rating: 4.5,
      );

      final state = DashboardState(recommendedRecipes: [recipe]);
      final next = state.copyWith(isLoading: true);
      expect(next.recommendedRecipes, hasLength( 1));
    });
  });

  group('DashboardNotifier.loadDashboard', () {
    test('populates all state fields on success', () async {
      final container = ProviderContainer();
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

    test('sets errorMessage when repository throws', () async {
      final container = ProviderContainer(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(
            _ThrowingDashboardRepo(),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(dashboardProvider.notifier).loadDashboard();

      final state = container.read(dashboardProvider);
      expect(state.errorMessage, isNotNull);
      expect(state.isLoading, false);
    });
    test(' keeps recommendedRecipes empty when repository throws', () async {
      final container = ProviderContainer(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(
            _ThrowingDashboardRepo(),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(dashboardProvider.notifier).loadDashboard();

      expect(
        container.read(dashboardProvider).recommendedRecipes,
        isEmpty,
      );
    });

    test('sets isLoading  to false after error ', () async {
      final container = ProviderContainer(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(
            _ThrowingDashboardRepo(),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(dashboardProvider.notifier).loadDashboard();

      expect(container.read(dashboardProvider).isLoading, false);
    });
  });
}
