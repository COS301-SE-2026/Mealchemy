//holds recipe list, per-recipe detail, cuisine types, and add-recipe submission state
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/providers/api_service_provider.dart';
import '../../vault/providers/vault_repository_provider.dart';
import '../../vault/repositories/vault_repository.dart';
import '../../vault/models/vault.dart';
import '../models/recipe.dart';
import '../repositories/api_recipe_repository.dart';
import '../repositories/mock_recipe_repository.dart';
import '../repositories/recipe_repository.dart';

//selects mock/API repo
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  if (AppConfig.mockRecipe) {
    return MockRecipeRepository();
  }

  return ApiRecipeRepository(ref.read(dioProvider));
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
  AddRecipeNotifier(this._repository, this._vaultRepository, this._ref)
      : super(const AddRecipeState());

  final RecipeRepository _repository;
  final VaultRepository _vaultRepository;
  final Ref _ref;

  static const _defaultFolderName = 'My Recipes';
  Future<int> _resolveDefaultFolderId() async {
    final vaults = await _vaultRepository.getMyVaults();
    final privateVault = vaults.firstWhere(
      (v) => v.vaultType == VaultTypes.private,
      orElse: () => throw StateError('No private vault found for this user.'),
    );

    final folders = await _vaultRepository.getFolders(privateVault.vaultId);
    final existing = folders.where((f) => f.folderName == _defaultFolderName);
    if (existing.isNotEmpty) return existing.first.folderId;

    final created = await _vaultRepository.createFolder(
      privateVault.vaultId,
      _defaultFolderName,
    );
    return created.folderId;
  }

  Future<Recipe?> submit(Recipe recipe, {int? folderId, int? recipeId}) async {
    final missing = recipe.title.trim().isEmpty ||
        (recipe.cuisineType ?? '').isEmpty ||
        recipe.prepTimeMins == null ||
        recipe.cookingTimeMins == null ||
        recipe.servingSize == null;
    if (missing) {
      state = const AddRecipeState(
          errorMessage: 'Please fill in all required fields.');
      return null;
    }

    //replace whole state
    state = const AddRecipeState(isSubmitting: true);

     try {
      final Recipe result;
      if (recipeId != null) {
        result = await _repository.updateRecipe(recipeId, recipe);
      } else {
        final targetFolderId = folderId ?? await _resolveDefaultFolderId();
        result = await _repository.addRecipe(recipe, targetFolderId);
      }
      state = const AddRecipeState(isSuccess: true);
      _ref.invalidate(recipesProvider);
      return result;
    } on DioException catch (e) {
      final serverMessage = e.response?.data is Map
          ? (e.response?.data as Map)['message'] as String?
          : null;
      state = AddRecipeState(
        errorMessage: serverMessage ?? 'Could not save recipe. Try again.',
      );
      return null;
    } catch (_) {
      state = const AddRecipeState(
          errorMessage: 'Could not save recipe. Try again.');
      return null;
    }
  }

  //return state to default
  void reset() {
    state = const AddRecipeState();
  }
}

final addRecipeProvider =
    StateNotifierProvider<AddRecipeNotifier, AddRecipeState>((ref) {
  return AddRecipeNotifier(ref.watch(recipeRepositoryProvider),  ref.watch(vaultRepositoryProvider), ref,);
});
