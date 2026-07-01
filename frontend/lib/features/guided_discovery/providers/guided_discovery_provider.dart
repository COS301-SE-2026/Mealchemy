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
    required this.allRecipes,
    this.currentIndex = 0,
    this.likedRecipeIds = const [],
    this.dislikedRecipeIds = const [],
    this.selectedFilter = 'All',
  });

  final List<DiscoveryRecipe> allRecipes;
  final int currentIndex;
  final List<String> likedRecipeIds;
  final List<String> dislikedRecipeIds;
  final String selectedFilter;

  //recipes that match selected filter
  List<DiscoveryRecipe> get recipes {
    if (selectedFilter == 'All') return allRecipes;

    return allRecipes.where((recipe) {
      return recipe.tags.contains(selectedFilter);
    }).toList();
  }

  //returns recipe being displayed to user
  DiscoveryRecipe? get currentRecipe {
    if (currentIndex >= recipes.length) return null;
    return recipes[currentIndex];
  }

  //shows if all recipes have been reviewed
  bool get isComplete => currentIndex >= recipes.length;

  //shows user progress through current filtered recipe stack
  int get totalRecipes => recipes.length;

  //shows how many recipes have been reviewed in current filtered recipe stack
  int get viewedRecipeCount {
    if (recipes.isEmpty) return 0;
    return currentIndex.clamp(0, recipes.length);
  }

  //recipes user liked
  List<DiscoveryRecipe> get likedRecipes {
    return allRecipes.where((recipe) {
      return likedRecipeIds.contains(recipe.id);
    }).toList();
  }

  //recipes user disliked
  List<DiscoveryRecipe> get dislikedRecipes {
    return allRecipes.where((recipe) {
      return dislikedRecipeIds.contains(recipe.id);
    }).toList();
  }

  //mock heuristic taste tags based on liked recipes
  List<String> get topTasteSignals {
    final tagCounts = <String, int>{};

    for (final recipe in likedRecipes) {
      for (final tag in recipe.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTags.map((entry) => entry.key).take(3).toList();
  }

  //mock recommended recipe based on liked recipe tags
  DiscoveryRecipe? get recommendedRecipe {
    if (recipes.isEmpty) return null;

    final likedIds = likedRecipeIds.toSet();
    final dislikedIds = dislikedRecipeIds.toSet();
    final tasteSignals = topTasteSignals.toSet();

    final unreviewedRecipes = allRecipes.where((recipe) {
      return !likedIds.contains(recipe.id) && !dislikedIds.contains(recipe.id);
    }).toList();

    if (unreviewedRecipes.isEmpty) {
      return likedRecipes.isNotEmpty ? likedRecipes.first : allRecipes.first;
    }

    unreviewedRecipes.sort((a, b) {
      final aScore = a.tags.where(tasteSignals.contains).length;
      final bScore = b.tags.where(tasteSignals.contains).length;

      return bScore.compareTo(aScore);
    });

    return unreviewedRecipes.first;
  }

  GuidedDiscoveryState copyWith({
    List<DiscoveryRecipe>? allRecipes,
    int? currentIndex,
    List<String>? likedRecipeIds,
    List<String>? dislikedRecipeIds,
    String? selectedFilter,
  }) {
    return GuidedDiscoveryState(
      allRecipes: allRecipes ?? this.allRecipes,
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

    return GuidedDiscoveryState(allRecipes: recipes);
  }

  //updates filter
  void selectFilter(String filter) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        selectedFilter: filter,
        currentIndex: 0,
      ),
    );
  }

  //like recipe
  void likeCurrentRecipe() {
    final current = state.valueOrNull;
    final recipe = current?.currentRecipe;
    if (current == null || recipe == null) return;

    state = AsyncData(
      current.copyWith(
        currentIndex: current.currentIndex + 1,
        likedRecipeIds: current.likedRecipeIds.contains(recipe.id)
            ? current.likedRecipeIds
            : [...current.likedRecipeIds, recipe.id],
        dislikedRecipeIds:
            current.dislikedRecipeIds.where((id) => id != recipe.id).toList(),
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
        dislikedRecipeIds: current.dislikedRecipeIds.contains(recipe.id)
            ? current.dislikedRecipeIds
            : [...current.dislikedRecipeIds, recipe.id],
        likedRecipeIds:
            current.likedRecipeIds.where((id) => id != recipe.id).toList(),
      ),
    );
  }

  //resets
  Future<void> resetDiscovery() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final recipes = await _repository.getDiscoveryRecipes();
      return GuidedDiscoveryState(allRecipes: recipes);
    });
  }
}
