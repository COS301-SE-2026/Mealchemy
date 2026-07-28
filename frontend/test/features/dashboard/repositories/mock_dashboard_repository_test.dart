import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/dashboard/repositories/mock_dashboard_repository.dart';

void main() {
  group('MockDashboardRepository.getDisplayName', () {
    test('returns a non-empty display name', () async {
      final repository = MockDashboardRepository();
      final name = await repository.getDisplayName();

      expect(name, isNotEmpty);
    });
  });

  group('MockDashboardRepository.getPantryItemCount', () {
    test('returns a positive item count', () async {
      final repository = MockDashboardRepository();
      final count = await repository.getPantryItemCount();

      expect(count, greaterThan(0));
    });
  });
  
  group('MockDashboardRepository.getSmartSuggestionItemsAway', () {
    test('returns a non-negative value', () async {
      final repository = MockDashboardRepository();
      final itemsAway = await repository.getSmartSuggestionItemsAway();
      expect(itemsAway, greaterThanOrEqualTo(0));
    });
  });

  group('MockDashboardRepository.getSmartSuggestionRecipeCount', () {
    test('returns a positive recipe count', () async {
      final repository = MockDashboardRepository();
      final count = await repository.getSmartSuggestionRecipeCount();
      expect(count, greaterThan(0));
    });
  });

  group('MockDashboardRepository.getRecommendedRecipes', () {
    test('returns a non-empty  list', () async {
      final repository = MockDashboardRepository();
      final recipes = await repository.getRecommendedRecipes();

      expect(recipes, isNotEmpty);
    });

    test('every recipe  has a non-empty title', () async {
      final repository = MockDashboardRepository();
      final recipes = await repository.getRecommendedRecipes();

      for (final item in recipes) {
        expect(item.recipe.title, isNotEmpty);
      }
    });

    test('every recipe  has a matchPercent ', () async {
      final repository = MockDashboardRepository();
      final recipes = await repository.getRecommendedRecipes();
      for (final item in recipes) {
        expect(item.matchPercent, inInclusiveRange(0, 100));
      }
    });

    test('every recipe has a non-empty tag', () async {
      final repository = MockDashboardRepository();
      final recipes = await repository.getRecommendedRecipes();
      for (final item in recipes) {
        expect(item.tag, isNotEmpty);
      }
    });

    test('every recipe has a rating greater than 0', () async {
      final repository = MockDashboardRepository();
      final recipes = await repository.getRecommendedRecipes();

      for (final item in recipes) {
        expect(item.rating, greaterThan(0));
      }
    });
  });

  group('MockDashboardRepository.getTrendingRecipes', () {
    test('returns a non-empty list', () async {
      final repository = MockDashboardRepository();
      final trending = await repository.getTrendingRecipes();

      expect(trending, isNotEmpty);
    });

    test('every trending item has a non-empty title', () async {
      final repository = MockDashboardRepository();
      final trending = await repository.getTrendingRecipes();
      for (final item in trending) {
        expect(item.recipe.title, isNotEmpty);
      }
    });

    test('every trending item has a non-empty subtitle', () async {
      final repository = MockDashboardRepository();
      final trending = await repository.getTrendingRecipes();
      for (final item in trending) {
        expect(item.subtitle, isNotEmpty);
      }
    });
  });
}