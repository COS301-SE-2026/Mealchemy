import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../models/discovery_recipe.dart';
import '../repositories/guided_discovery_repository.dart';
import '../repositories/mock_guided_discovery_repository.dart';

final guidedDiscoveryRepositoryProvider =
    Provider<GuidedDiscoveryRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockGuidedDiscoveryRepository();
  }

  //API repo will replace this once the backend endpoint exists
  return MockGuidedDiscoveryRepository();
});

//state management provider
final guidedDiscoveryProvider =
    AsyncNotifierProvider<GuidedDiscoveryNotifier, GuidedDiscoveryState>(
  GuidedDiscoveryNotifier.new,
);

//current state of Guided Discovery flow. tracks recipes, user interactions, filter
class GuidedDiscoveryState {
  const GuidedDiscoveryState({
    required this.recipes,
    this.currentIndex = 0,
    this.likedRecipeIds = const [],
    this.dislikedRecipeIds = const [],
    this.selectedFilter = 'All',
  });

  final List<DiscoveryRecipe> recipes;
  final int currentIndex;
  final List<String> likedRecipeIds;
  final List<String> dislikedRecipeIds;
  final String selectedFilter;

  //returns recipe being displayed to user
  DiscoveryRecipe? get currentRecipe {
    if (currentIndex >= recipes.length) return null;
    return recipes[currentIndex];
  }

  //shows if all recipes have been reviewed
  bool get isComplete => currentIndex >= recipes.length;

  GuidedDiscoveryState copyWith({
    List<DiscoveryRecipe>? recipes,
    int? currentIndex,
    List<String>? likedRecipeIds,
    List<String>? dislikedRecipeIds,
    String? selectedFilter,
  }) {
    return GuidedDiscoveryState(
      recipes: recipes ?? this.recipes,
      currentIndex: currentIndex ?? this.currentIndex,
      likedRecipeIds: likedRecipeIds ?? this.likedRecipeIds,
      dislikedRecipeIds: dislikedRecipeIds ?? this.dislikedRecipeIds,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

//handles recipe interactions and updates state
class GuidedDiscoveryNotifier extends AsyncNotifier<GuidedDiscoveryState> {
  late final GuidedDiscoveryRepository _repository;

  //loads initial set of recipe recommendations
  @override
  Future<GuidedDiscoveryState> build() async {
    _repository = ref.watch(guidedDiscoveryRepositoryProvider);

    final recipes = await _repository.getDiscoveryRecipes();

    return GuidedDiscoveryState(recipes: recipes);
  }

  //updates filter 
  void selectFilter(String filter) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(selectedFilter: filter));
  }

  //like recipe
  void likeCurrentRecipe() {
    final current = state.valueOrNull;
    final recipe = current?.currentRecipe;
    if (current == null || recipe == null) return;

    state = AsyncData(
      current.copyWith(
        currentIndex: current.currentIndex + 1,
        likedRecipeIds: [...current.likedRecipeIds, recipe.id],
      ),
    );
  }

  //dislike recipe
  void dislikeCurrentRecipe() {
    final current = state.valueOrNull;
    final recipe = current?.currentRecipe;
    if (current == null || recipe == null) return;

    state = AsyncData(
      current.copyWith(
        currentIndex: current.currentIndex + 1,
        dislikedRecipeIds: [...current.dislikedRecipeIds, recipe.id],
      ),
    );
  }

  //resets
  Future<void> resetDiscovery() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final recipes = await _repository.getDiscoveryRecipes();
      return GuidedDiscoveryState(recipes: recipes);
    });
  }
}