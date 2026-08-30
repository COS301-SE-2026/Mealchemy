//holds recipe list, per-recipe detail, cuisine types, and add-recipe submission state
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/providers/api_service_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../offline/data/offline_cache_policy.dart';
import '../../offline/providers/offline_cache_provider.dart';
import '../../offline/repositories/cached_recipe_repository.dart';
import '../../vault/providers/vault_repository_provider.dart';
import '../../vault/repositories/vault_repository.dart';
import '../../vault/models/vault.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../models/recipe_step.dart';
import '../models/unit_of_measurement.dart';
import '../repositories/api_recipe_repository.dart';
import '../repositories/mock_recipe_repository.dart';
import '../repositories/recipe_repository.dart';

final remoteRecipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return ApiRecipeRepository(ref.read(dioProvider));
});

// Selects mock data or the cache-decorated API repository.
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  if (AppConfig.mockRecipe) return MockRecipeRepository();
  final remote = ref.watch(remoteRecipeRepositoryProvider);
  final viewerUserId = ref.watch(activeIdentityProvider);
  if (viewerUserId == null) return remote;

  return CachedRecipeRepository(
    remote: remote,
    cache: ref.watch(offlineCacheStoreProvider),
    viewerUserId: viewerUserId,
  );
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

//full recipe for the with metadata  ingredients  steps
final recipeDetailProvider =
    FutureProvider.family<Recipe, int>((ref, id) async {
  if (AppConfig.mockRecipe) {
    final repository = ref.watch(recipeRepositoryProvider);
    final results = await Future.wait([
      repository.getRecipeById(id),
      repository.getRecipeIngredients(id),
      repository.getRecipeSteps(id),
    ]);
    return (results[0] as Recipe).copyWith(
      ingredients: results[1] as List<RecipeIngredient>,
      steps: results[2] as List<RecipeStep>,
    );
  }

  final repository = ref.watch(remoteRecipeRepositoryProvider);
  final viewerUserId = ref.watch(activeIdentityProvider);
  final cache = ref.watch(offlineCacheStoreProvider);
  try {
    final results = await Future.wait([
      repository.getRecipeById(id),
      repository.getRecipeIngredients(id),
      repository.getRecipeSteps(id),
    ]);
    final completeRecipe = (results[0] as Recipe).copyWith(
      ingredients: results[1] as List<RecipeIngredient>,
      steps: results[2] as List<RecipeStep>,
    );
    if (viewerUserId != null) {
      await cache.storeCompleteRecipe(
        viewerUserId: viewerUserId,
        recipe: completeRecipe,
        syncedAt: DateTime.now().toUtc(),
      );
    }
    return completeRecipe;
  } catch (error) {
    if (!isOfflineTransportFailure(error) || viewerUserId == null) rethrow;
    final cached = await cache.readCompleteRecipe(
      viewerUserId: viewerUserId,
      recipeId: id,
    );
    if (cached == null) rethrow;
    return cached;
  }
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

  Future<Recipe?> submit(Recipe recipe,
      {int? folderId, int? recipeId, bool removePhoto = false}) async {
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
        result = await _repository.updateRecipeFull(recipeId, recipe,
            removePhoto: removePhoto);
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
  return AddRecipeNotifier(
    ref.watch(recipeRepositoryProvider),
    ref.watch(vaultRepositoryProvider),
    ref,
  );
});

final unitsProvider = FutureProvider<List<UnitOfMeasurement>>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getUnits();
});

final deleteRecipeProvider = Provider((ref) {
  return (int recipeId) async {
    final repository = ref.read(recipeRepositoryProvider);
    await repository.deleteRecipe(recipeId);
    ref.invalidate(recipesProvider);
  };
});