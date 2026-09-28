import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/providers/recipe_provider.dart';
import 'package:mealchemy/core/constants/app_config.dart';
import 'package:flutter/foundation.dart';
import '../models/vault.dart';
import '../models/vault_folder.dart';
import '../models/vault_folder_recipe.dart';
import '../providers/vault_repository_provider.dart';
import '../models/vault_member.dart';
import '../../external_links/models/link.dart';
import '../../external_links/providers/link_provider.dart';
import 'shared_vault_access_provider.dart';

// Vaults provider
final vaultsProvider = FutureProvider<List<Vault>>((ref) async {
  final auth = ref.watch(authProvider);
  debugPrint(
      'vault: userId=${auth.userId} loggedIn=${auth.isLoggedIn} mock=${AppConfig.useMockData}');
  if (auth.userId == null) return [];
  return ref.watch(vaultRepositoryProvider).getMyVaults();
});

// Vault folders provider
final vaultFoldersProvider =
    FutureProvider.family<List<VaultFolder>, int>((ref, vaultId) {
  ref.watch(vaultSessionProvider);
  return ref.watch(vaultRepositoryProvider).getFolders(vaultId);
});

// Raw folder recipes provider
final folderRecipesProvider =
    FutureProvider.family<List<VaultFolderRecipe>, int>((ref, folderId) {
  ref.watch(vaultSessionProvider);
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

final selectedVaultIdProvider = StateProvider<int?>((ref) {
  ref.watch(vaultSessionProvider.select((session) => session.userId));
  return null;
});

final isSharedModeProvider = StateProvider<bool>((ref) {
  ref.watch(vaultSessionProvider.select((session) => session.userId));
  return false;
});

final selectedVaultProvider = Provider<Vault?>((ref) {
  final vaults = ref.watch(vaultsProvider).valueOrNull;
  if (vaults == null || vaults.isEmpty) return null;

  if (!ref.watch(isSharedModeProvider)) {
    for (final v in vaults) {
      if (v.vaultType == VaultTypes.private) return v;
    }
    return vaults.first;
  }

  final shared = vaults.where((v) => v.vaultType == VaultTypes.shared).toList();
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
  ref.watch(vaultSessionProvider);
  return ref.watch(vaultRepositoryProvider).getMembers(vaultId);
});

// Private vault folders for the recipe folder picker
final privateFoldersProvider = FutureProvider<List<VaultFolder>>((ref) async {
  final private = ref.watch(privateVaultProvider);
  if (private == null) return [];
  return ref.watch(vaultRepositoryProvider).getFolders(private.vaultId);
});

final deleteFolderRecipeProvider =
    Provider.family<Future<void> Function(int recipeId), int>((ref, folderId) {
  return (int recipeId) async {
    final repository = ref.read(recipeRepositoryProvider);
    await repository.deleteRecipe(recipeId);
    ref.invalidate(recipesProvider);
    ref.invalidate(folderRecipesProvider(folderId));
  };
});

final vaultSearchQueryProvider = StateProvider<String>((ref) {
  ref.watch(vaultSessionProvider.select((session) => session.userId));
  return '';
});

typedef VaultSearchRequest = ({
  int vaultId,
  bool includeLinks,
  String query,
});

class VaultRecipeSearchResult {
  const VaultRecipeSearchResult({
    required this.folder,
    required this.recipe,
  });

  final VaultFolder folder;
  final Recipe recipe;
}

class VaultSearchResults {
  const VaultSearchResults({
    required this.recipes,
    required this.links,
  });

  final List<VaultRecipeSearchResult> recipes;
  final List<Link> links;

  bool get isEmpty => recipes.isEmpty && links.isEmpty;
}

final vaultSearchResultsProvider =
    FutureProvider.family<VaultSearchResults, VaultSearchRequest>((
  ref,
  request,
) async {
  final query = request.query.trim().toLowerCase();

  if (query.isEmpty) {
    return const VaultSearchResults(
      recipes: [],
      links: [],
    );
  }

  final folders = await ref.watch(
    vaultFoldersProvider(request.vaultId).future,
  );

  final recipeResults = <VaultRecipeSearchResult>[];

  await Future.wait(
    folders.map((folder) async {
      final recipes = await ref.watch(
        folderRecipeDisplayProvider(folder.folderId).future,
      );

      final folderMatches = folder.folderName.toLowerCase().contains(query);

      for (final recipe in recipes) {
        final recipeMatches = [
          recipe.title,
          recipe.description,
          recipe.cuisineType,
        ].whereType<String>().any(
              (value) => value.toLowerCase().contains(query),
            );

        if (folderMatches || recipeMatches) {
          recipeResults.add(
            VaultRecipeSearchResult(
              folder: folder,
              recipe: recipe,
            ),
          );
        }
      }
    }),
  );

  var linkResults = <Link>[];

  if (request.includeLinks) {
    final links = await ref.watch(linksProvider.future);

    linkResults = links.where((link) {
      return link.name.toLowerCase().contains(query) ||
          link.url.toLowerCase().contains(query);
    }).toList();
  }

  return VaultSearchResults(
    recipes: recipeResults,
    links: linkResults,
  );
});
