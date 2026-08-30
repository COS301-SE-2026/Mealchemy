import '../../vault/models/vault.dart';
import '../../vault/models/vault_folder.dart';
import '../../vault/models/vault_folder_recipe.dart';
import '../../vault/models/vault_member.dart';
import '../../vault/repositories/vault_repository.dart';
import '../data/offline_cache_policy.dart';
import '../data/offline_cache_store.dart';

class CachedVaultRepository implements VaultRepository {
  CachedVaultRepository({
    required VaultRepository remote,
    required OfflineCacheStore cache,
    required int? viewerUserId,
  })  : _remote = remote,
        _cache = cache,
        _viewerUserId = viewerUserId;

  final VaultRepository _remote;
  final OfflineCacheStore _cache;
  final int? _viewerUserId;

  @override
  Future<List<Vault>> getMyVaults() async {
    try {
      final vaults = await _remote.getMyVaults();
      final viewerUserId = _viewerUserId;
      if (viewerUserId != null) {
        await _cache.replaceVaultsFromCompleteFetch(
          viewerUserId: viewerUserId,
          vaults: vaults,
          syncedAt: DateTime.now().toUtc(),
        );
      }
      return vaults;
    } catch (error) {
      final viewerUserId = _viewerUserId;
      if (!isOfflineTransportFailure(error) || viewerUserId == null) rethrow;
      return _cache.readVaults(viewerUserId: viewerUserId);
    }
  }

  @override
  Future<Vault> getVaultById(int vaultId) async {
    try {
      return await _remote.getVaultById(vaultId);
    } catch (error) {
      final viewerUserId = _viewerUserId;
      if (!isOfflineTransportFailure(error) || viewerUserId == null) rethrow;
      final cached = await _cache.readVault(
        viewerUserId: viewerUserId,
        vaultId: vaultId,
      );
      if (cached == null) rethrow;
      return cached;
    }
  }

  @override
  Future<List<VaultFolder>> getFolders(int vaultId) async {
    try {
      final folders = await _remote.getFolders(vaultId);
      final viewerUserId = _viewerUserId;
      if (viewerUserId != null) {
        await _cache.replaceFoldersFromCompleteFetch(
          viewerUserId: viewerUserId,
          vaultId: vaultId,
          folders: folders,
          syncedAt: DateTime.now().toUtc(),
        );
      }
      return folders;
    } catch (error) {
      final viewerUserId = _viewerUserId;
      if (!isOfflineTransportFailure(error) || viewerUserId == null) rethrow;
      return _cache.readFolders(
        viewerUserId: viewerUserId,
        vaultId: vaultId,
      );
    }
  }

  @override
  Future<List<VaultFolderRecipe>> getFolderRecipes(int folderId) async {
    try {
      final folderRecipes = await _remote.getFolderRecipes(folderId);
      final viewerUserId = _viewerUserId;
      if (viewerUserId != null) {
        await _cache.replaceFolderRecipesFromCompleteFetch(
          viewerUserId: viewerUserId,
          folderId: folderId,
          folderRecipes: folderRecipes,
          syncedAt: DateTime.now().toUtc(),
        );
      }
      return folderRecipes;
    } catch (error) {
      final viewerUserId = _viewerUserId;
      if (!isOfflineTransportFailure(error) || viewerUserId == null) rethrow;
      return _cache.readFolderRecipes(
        viewerUserId: viewerUserId,
        folderId: folderId,
      );
    }
  }

  @override
  Future<Vault> createVault(String name) => _remote.createVault(name);

  @override
  Future<void> deleteVault(int vaultId) => _remote.deleteVault(vaultId);

  @override
  Future<VaultFolder> createFolder(int vaultId, String folderName) {
    return _remote.createFolder(vaultId, folderName);
  }

  @override
  Future<void> deleteFolder(int folderId, int vaultId) {
    return _remote.deleteFolder(folderId, vaultId);
  }

  @override
  Future<VaultFolder> renameFolder(
    int folderId,
    int vaultId,
    String folderName,
  ) {
    return _remote.renameFolder(folderId, vaultId, folderName);
  }

  @override
  Future<VaultFolderRecipe> addRecipeToFolder(int folderId, int recipeId) {
    return _remote.addRecipeToFolder(folderId, recipeId);
  }

  @override
  Future<VaultFolderRecipe> moveRecipe(
    int folderRecipeId,
    int targetFolderId,
  ) {
    return _remote.moveRecipe(folderRecipeId, targetFolderId);
  }

  @override
  Future<void> removeRecipeFromFolder(int folderRecipId) {
    return _remote.removeRecipeFromFolder(folderRecipId);
  }

  @override
  Future<List<VaultFolderRecipe>> getFoldersForRecipe(int recipeId) {
    return _remote.getFoldersForRecipe(recipeId);
  }

  @override
  Future<List<VaultMember>> getMembers(int vaultId) {
    return _remote.getMembers(vaultId);
  }

  @override
  Future<VaultMember> addMember(int vaultId, String email) {
    return _remote.addMember(vaultId, email);
  }

  @override
  Future<void> removeMember(int vaultId, String email) {
    return _remote.removeMember(vaultId, email);
  }
}
