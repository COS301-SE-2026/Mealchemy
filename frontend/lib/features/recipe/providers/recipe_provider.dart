//holds recipe list, per-recipe detail, cuisine types, and add-recipe submission state
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../models/recipe.dart';
import '../repositories/api_recipe_repository.dart';
import '../repositories/mock_recipe_repository.dart';
import '../repositories/recipe_repository.dart';

//selects mock/API repo
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockRecipeRepository();
  }

  return ApiRecipeRepository();
});

//list of recipes (for list / vault views)
final recipesProvider = FutureProvider<List<Recipe>>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getRecipes();
});

//take recipe id as paramter
//each unique id gets its own cached future
final recipeByIdProvider = FutureProvider.family<Recipe, int>((ref, id) {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getRecipeById(id);
});

//cuisine_type_enum values (used by add-recipe selector)
final cuisineTypesProvider = FutureProvider<List<String>>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getCuisineTypes();
});

//submission state for the add recipe screen
//clears error previous errors
class AddRecipeState {
  const AddRecipeState({
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;

  AddRecipeState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return AddRecipeState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class AddRecipeNotifier extends StateNotifier<AddRecipeState> {
  AddRecipeNotifier(this._repository) : super(const AddRecipeState());

  final RecipeRepository _repository;

  Future<void> submit(Recipe recipe) async {
    if (recipe.title.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Title is required');
      return;
    }

  //replace whole state
    state = const AddRecipeState(isSubmitting: true);

    try {
      await _repository.addRecipe(recipe);
      state = const AddRecipeState(isSuccess: true);
    } catch (_) {
      state = const AddRecipeState(errorMessage: 'Could not save recipe. Try again.');
    }
  }

  //return state to default
  void reset() {
    state = const AddRecipeState();
  }
}

final addRecipeProvider =
    StateNotifierProvider<AddRecipeNotifier, AddRecipeState>((ref) {
  return AddRecipeNotifier(ref.watch(recipeRepositoryProvider));
});
