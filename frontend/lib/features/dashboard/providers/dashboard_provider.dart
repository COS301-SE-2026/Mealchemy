import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/features/auth/models/user.dart';
import 'package:mealchemy/features/dashboard/models/dashboard_recipe_card_data.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';

//State
class DashboardState {
  final bool isLoading;
  final String? errorMessage;
  final User? currentUser;
  final int smartSuggestionItemsAway;
  final int smartSuggestionRecipeCount;
  final List<DashboardRecipeCardData> recommendedRecipes;

  const DashboardState({
    this.isLoading = false,
    this.errorMessage,
    this.currentUser,
    this.smartSuggestionItemsAway = 0,
    this.smartSuggestionRecipeCount = 0,
    this.recommendedRecipes = const [],
  });

  DashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    User? currentUser,
    int? smartSuggestionItemsAway,
    int? smartSuggestionRecipeCount,
    List<DashboardRecipeCardData>? recommendedRecipes,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentUser: currentUser ?? this.currentUser,
      smartSuggestionItemsAway:
          smartSuggestionItemsAway ?? this.smartSuggestionItemsAway,
      smartSuggestionRecipeCount:
          smartSuggestionRecipeCount ?? this.smartSuggestionRecipeCount,
      recommendedRecipes: recommendedRecipes ?? this.recommendedRecipes,
    );
  }
}

//Notifier
class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier(this._ref) : super(const DashboardState());

  final Ref _ref;
  Future<void> loadDashboard() async {
    //Replace with real API call later
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(isLoading: true, errorMessage: null);
    final recipes = await _ref.read(recipesProvider.future);
    final mockSuggestionOverlay = [
      (matchPercent: 92, tag: 'HIGH PROTEIN', rating: 4.9),
      (matchPercent: 85, tag: 'HIGH PROTEIN', rating: 4.7),
    ];

    final recommended = recipes
        .take(mockSuggestionOverlay.length)
        .toList()
        .asMap()
        .entries
        .map((entry) {
      final overlay = mockSuggestionOverlay[entry.key];
      return DashboardRecipeCardData(
        recipe: entry.value,
        matchPercent: overlay.matchPercent,
        tag: overlay.tag,
        rating: overlay.rating,
      );
    }).toList();

    state = state.copyWith(
      isLoading: false,
      currentUser: const User(
        userId: 1,
        email: 'mutombo@mealchemy.com',
        displayName: 'Mutombo',
        role: 'user',
      ),
      //smart suggestion data will come from the reicipe suggestion
      //repository once that feature is built
      smartSuggestionItemsAway: 3,
      smartSuggestionRecipeCount: 10,
      recommendedRecipes: recommended,
    );
  }
}

//Provider
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref);
});
