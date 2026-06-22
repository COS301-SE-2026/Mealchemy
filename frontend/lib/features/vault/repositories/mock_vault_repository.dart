import 'vault_repository.dart';
import '../models/vault.dart';
import '../models/vault_folder.dart';
import '../models/vault_folder_recipe.dart';

class MockVaultRepository implements VaultRepository {
  // Mock data
  static final List<Vault> _vaults = [
    Vault(
      vaultId: 1,
      ownerId: 1,
      vaultType: 'PRIVATE',
      name: 'My Vault',
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  static final List<VaultFolder> _folders = [
    VaultFolder(
      folderId: 1,
      vaultId: 1,
      folderName: 'Breakfast',
      createdAt: DateTime(2026, 1, 1),
    ),
    VaultFolder(
      folderId: 2,
      vaultId: 1,
      folderName: 'Dinner',
      createdAt: DateTime(2026, 1, 2),
    ),
  ];

  static final List<VaultFolderRecipe> _folderRecipes = [
    VaultFolderRecipe(
      id: 1,
      folderId: 1,
      recipeId: 1,
      addedAt: DateTime(2026, 1, 1),
    ),
    VaultFolderRecipe(
      id: 2,
      folderId: 1,
      recipeId: 2,
      addedAt: DateTime(2026, 1, 2),
    ),
  ];

  // Vaults
  @override
  Future<List<Vault>> getVaultsByOwnerId(int ownerId) async {
    return _vaults.where((v) => v.ownerId == ownerId).toList();
  }

  @override
  Future<Vault> getVaultById(int id) async {
    return _vaults.firstWhere((v) => v.vaultId == id);
  }

  @override
  Future<Vault> createVault(int ownerId, String vaultType, String name) async {
    return Vault(
      vaultId: 99,
      ownerId: ownerId,
      vaultType: vaultType,
      name: name,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Vault> updateVault(
      int id, int ownerId, String vaultType, String name) async {
    return Vault(
      vaultId: id,
      ownerId: ownerId,
      vaultType: vaultType,
      name: name,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteVault(int id) async {}

  // Folders
  @override
  Future<List<VaultFolder>> getFoldersByVaultId(int vaultId) async {
    return _folders.where((f) => f.vaultId == vaultId).toList();
  }

  @override
  Future<VaultFolder> getFolderByName(String name) async {
    return _folders.firstWhere((f) => f.folderName == name);
  }

  @override
  Future<VaultFolder> getFolderById(int id) async {
    return _folders.firstWhere((f) => f.folderId == id);
  }

  @override
  Future<VaultFolder> createFolder(int vaultId, String folderName) async {
    return VaultFolder(
      folderId: 99,
      vaultId: vaultId,
      folderName: folderName,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<VaultFolder> updateFolder(
      int id, int vaultId, String folderName) async {
    return VaultFolder(
      folderId: id,
      vaultId: vaultId,
      folderName: folderName,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteFolder(int id) async {}

  // Folder Recipes
  @override
  Future<List<VaultFolderRecipe>> getRecipesByFolderId(int folderId) async {
    return _folderRecipes.where((r) => r.folderId == folderId).toList();
  }

  @override
  Future<List<VaultFolderRecipe>> getFoldersByRecipeId(int recipeId) async {
    return _folderRecipes.where((r) => r.recipeId == recipeId).toList();
  }

  @override
  Future<VaultFolderRecipe> getFolderRecipeById(int id) async {
    return _folderRecipes.firstWhere((r) => r.id == id);
  }

  @override
  Future<VaultFolderRecipe> createFolderRecipe(
      int folderId, int recipeId) async {
    return VaultFolderRecipe(
      id: 99,
      folderId: folderId,
      recipeId: recipeId,
      addedAt: DateTime.now(),
    );
  }

  @override
  Future<VaultFolderRecipe> updateFolderRecipe(
      int id, int folderId, int recipeId) async {
    return VaultFolderRecipe(
      id: id,
      folderId: folderId,
      recipeId: recipeId,
      addedAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteFolderRecipe(int id) async {}
}
