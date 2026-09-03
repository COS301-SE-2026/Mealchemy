import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/constants/app_config.dart';
import 'package:mealchemy/features/dashboard/models/trending_recipe_data.dart';
import 'package:mealchemy/features/dashboard/repositories/api_dashboard_repository.dart';
import 'package:mealchemy/features/dashboard/repositories/dashboard_repository.dart';
import 'package:mealchemy/features/dashboard/repositories/mock_dashboard_repository.dart';
import 'package:mealchemy/features/guided_discovery/models/recommendation.dart';
import 'package:mealchemy/features/guided_discovery/providers/guided_discovery_provider.dart';
import 'package:mealchemy/features/guided_discovery/repositories/guided_discovery_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  if (AppConfig.mockDashboard) {
    return MockDashboardRepository();
  }
  return ApiDashboardRepository();
});
// State
class DashboardState {
  final bool isLoading;
  final String? errorMessage;
  final String displayName;
  final int pantryItemCount;
  final int smartSuggestionItemsAway;
  final int smartSuggestionRecipeCount;
  final List<Recommendation> recommendedRecipes;
  final List<TrendingRecipeData> trendingRecipes;

  const DashboardState({
    this.isLoading = false,
    this.errorMessage,
    this.displayName = '',
    this.pantryItemCount = 0,
    this.smartSuggestionItemsAway = 0,
    this.smartSuggestionRecipeCount = 0,
    this.recommendedRecipes = const [],
    this.trendingRecipes = const [],
  });

  DashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? displayName,
    int? pantryItemCount,
    int? smartSuggestionItemsAway,
    int? smartSuggestionRecipeCount,
    List<Recommendation>? recommendedRecipes,
    List<TrendingRecipeData>? trendingRecipes,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      displayName: displayName ?? this.displayName,
      pantryItemCount: pantryItemCount ?? this.pantryItemCount,
      smartSuggestionItemsAway:
          smartSuggestionItemsAway ?? this.smartSuggestionItemsAway,
      smartSuggestionRecipeCount:
          smartSuggestionRecipeCount ?? this.smartSuggestionRecipeCount,
      recommendedRecipes: recommendedRecipes ?? this.recommendedRecipes,
      trendingRecipes: trendingRecipes ?? this.trendingRecipes,
    );
  }
}
// Notifier
class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier(this._repository, this._guidedDiscoveryRepository)
      : super(const DashboardState());

  final DashboardRepository _repository;
  final GuidedDiscoveryRepository _guidedDiscoveryRepository;

  static const _dashboardRecommendationCount = 10;

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final displayName = await _repository.getDisplayName();
      final pantryItemCount = await _repository.getPantryItemCount();
      final itemsAway = await _repository.getSmartSuggestionItemsAway();
      final recipeCount = await _repository.getSmartSuggestionRecipeCount();
      final trending = await _repository.getTrendingRecipes();
      final recommended = await _loadRecommended();

      state = state.copyWith(
        isLoading: false,
        displayName: displayName,
        pantryItemCount: pantryItemCount,
        smartSuggestionItemsAway: itemsAway,
        smartSuggestionRecipeCount: recipeCount,
        recommendedRecipes: recommended,
        trendingRecipes: trending,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load dashboard. Please try again.',
      );
    }
  }

  // Reuses the guided-discovery recommendation pool, just capped to a
  // preview sized batch instead of the full swipe deck.
  Future<List<Recommendation>> _loadRecommended() async {
    try {
      return await _guidedDiscoveryRepository.getRecommendations(
        batchSize: _dashboardRecommendationCount,
      );
    } on EmptyRecommendationPool {
      return const [];
    }
  }
}

// Provider
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(
    ref.watch(dashboardRepositoryProvider),
    ref.watch(guidedDiscoveryRepositoryProvider),
  );
});