import '../models/vault_folder_recipe.dart';
import '../models/vault_folder.dart';
import '../models/vault.dart';

abstract class VaultRepository {
  // Vaults
  Future<List<Vault>> getVaultsByOwnerId(int ownerId);
  Future<Vault> getVaultById(int id);
  Future<Vault> createVault(int ownerId, String vaultType, String name);
  Future<Vault> updateVault(int id, int ownerId, String vaultType, String name);
  Future<void> deleteVault(int id);

  // Folders
  Future<List<VaultFolder>> getFoldersByVaultId(int vaultId);
  Future<VaultFolder> getFolderByName(String name);
  Future<VaultFolder> getFolderById(int id);
  Future<VaultFolder> createFolder(int vaultId, String folderName);
  Future<VaultFolder> updateFolder(int id, int vaultId, String folderName);
  Future<void> deleteFolder(int id);

  // Folder-recipes
  Future<List<VaultFolderRecipe>> getRecipesByFolderId(int folderId);
  Future<List<VaultFolderRecipe>> getFoldersByRecipeId(int recipeId);
  Future<VaultFolderRecipe> getFolderRecipeById(int id);
  Future<VaultFolderRecipe> createFolderRecipe(int folderId, int recipeId);
  Future<VaultFolderRecipe> updateFolderRecipe(int id, int folderId, int recipeId);
  Future<void> deleteFolderRecipe(int id);
}