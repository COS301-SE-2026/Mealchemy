import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/providers/api_service_provider.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/repositories/mock_recipe_repository.dart';
import 'package:mealchemy/features/vault/repositories/mock_vault_repository.dart';
import '../repositories/api_vault_repository.dart';
import '../repositories/vault_repository.dart';
import '../models/vault.dart';
import '../models/vault_folder.dart';
import '../models/vault_folder_recipe.dart';

// Toggleflutter run/ default is false now, have to include falg in flutter run command to use mock data
const bool _useMock = bool.fromEnvironment('USE_MOCK');

final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  if (_useMock) {
    return MockVaultRepository();
  }
  return ApiVaultRepository(ref.read(dioProvider));
});

// Vaults provider
final vaultsProvider = FutureProvider<List<Vault>>((ref) {
  final userId = ref.watch(authProvider).user?.id;
  if (userId == null) return Future.value([]);
  return ref.watch(vaultRepositoryProvider).getVaultsByOwnerId(userId);
});

// Vault folders provider
final vaultFoldersProvider =
    FutureProvider.family<List<VaultFolder>, int>((ref, vaultId) {
  return ref.watch(vaultRepositoryProvider).getFoldersByVaultId(vaultId);
});

// Raw folder recipes provider
final folderRecipesProvider =
    FutureProvider.family<List<VaultFolderRecipe>, int>((ref, folderId) {
  return ref.watch(vaultRepositoryProvider).getRecipesByFolderId(folderId);
});

// Display provider
final folderRecipeDisplayProvider =
    FutureProvider.family<List<Recipe>, int>((ref, folderId) async {
  final folderRecipes = await ref.watch(folderRecipesProvider(folderId).future);
  final mockRepo = MockRecipeRepository();

  final recipes = <Recipe>[];
  for (final fr in folderRecipes) {
    try {
      final recipe = await mockRepo.getRecipeById(fr.recipeId);
      recipes.add(recipe);
    } catch (_) {
      
    }
  }

  return recipes;
});
