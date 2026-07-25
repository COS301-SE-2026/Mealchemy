import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/providers/api_service_provider.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';
import 'package:mealchemy/core/constants/app_config.dart';
import 'package:flutter/foundation.dart';
import '../models/vault.dart';
import '../models/vault_folder.dart';
import '../models/vault_folder_recipe.dart';
import '../repositories/vault_repository.dart';
import '../repositories/mock_vault_repository.dart';
import '../repositories/api_vault_repository.dart';
import '../models/vault_member.dart';

final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockVaultRepository();
  }

  return ApiVaultRepository(ref.read(dioProvider));
});

// Vaults provider
final vaultsProvider = FutureProvider<List<Vault>>((ref) async {
  final auth = ref.watch(authProvider);
  debugPrint('vault: userId=${auth.userId} loggedIn=${auth.isLoggedIn} mock=${AppConfig.useMockData}');
  if (auth.userId == null) return [];
  return ref.watch(vaultRepositoryProvider).getMyVaults();
});

// Vault folders provider
final vaultFoldersProvider = FutureProvider.family<List<VaultFolder>, int>((ref, vaultId) {
  return ref.watch(vaultRepositoryProvider).getFolders(vaultId);
});

// Raw folder recipes provider
final folderRecipesProvider =
    FutureProvider.family<List<VaultFolderRecipe>, int>((ref, folderId) {
  return ref.watch(vaultRepositoryProvider).getFolderRecipes(folderId);
});

// Display provider
final folderRecipeDisplayProvider =
    FutureProvider.family<List<Recipe>, int>((ref, folderId) async {
  final folderRecipes = await ref.watch(folderRecipesProvider(folderId).future);
  final recipeRepository = ref.watch(recipeRepositoryProvider);

    final results = await Future.wait(
    folderRecipes.map((fr) async {
      try {
        return await recipeRepository.getRecipeById(fr.recipeId);
      } catch (_) {
        return null;
      }
    }),
  );

  return results.whereType<Recipe>().toList();
});

//Selecting a vault 

final selectedVaultIdProvider = StateProvider<int?>((ref) => null);
final isSharedModeProvider = StateProvider<bool>((ref) => false);

final selectedVaultProvider = Provider<Vault?>((ref) {
  final vaults = ref.watch(vaultsProvider).valueOrNull;
  if (vaults == null || vaults.isEmpty) return null;

  if (!ref.watch(isSharedModeProvider)) {
    for (final v in vaults) {
      if (v.vaultType == VaultTypes.private) return v;
    }
    return vaults.first;
  }

  final shared =
      vaults.where((v) => v.vaultType == VaultTypes.shared).toList();
  if (shared.isEmpty) return null;

  final selectedId = ref.watch(selectedVaultIdProvider);
  if (selectedId != null) {
    for (final v in shared) {
      if (v.vaultId == selectedId) return v;
    }
  }
  return shared.first;
});

// Shared vaults for the strip
final sharedVaultsProvider = Provider<List<Vault>>((ref) {
  final vaults = ref.watch(vaultsProvider).valueOrNull ?? const [];
  return vaults.where((v) => v.vaultType == VaultTypes.shared).toList();
});

// The users private vault
final privateVaultProvider = Provider<Vault?>((ref) {
  final vaults = ref.watch(vaultsProvider).valueOrNull ?? const [];
  for (final v in vaults) {
    if (v.vaultType == VaultTypes.private) return v;
  }
  return null;
});

final vaultMembersProvider =
    FutureProvider.family<List<VaultMember>, int>((ref, vaultId) {
  return ref.watch(vaultRepositoryProvider).getMembers(vaultId);
});