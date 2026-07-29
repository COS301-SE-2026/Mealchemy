import '../models/vault_folder_recipe.dart';
import '../models/vault_folder.dart';
import '../models/vault_member.dart';
import '../models/vault.dart';

abstract class VaultRepository {
  // Vaults
  Future<List<Vault>> getMyVaults();
  Future<Vault> getVaultById(int vaultId);
  Future<Vault> createVault(String name);
  Future<void> deleteVault(int vaultId);
  //Future<Vault> renameVault(int vaultId, String vaultType, String name);

  // Folders
  Future<List<VaultFolder>> getFolders(int vaultId);
  Future<VaultFolder> createFolder(int vaultId, String folderName);
  Future<VaultFolder> renameFolder(int folderId, int vaultId, String folderName);
  Future<void> deleteFolder(int folderId, int vaultId);

  // Folder-recipes
  Future<List<VaultFolderRecipe>> getFolderRecipes(int folderId);
  Future<List<VaultFolderRecipe>> getFoldersForRecipe(int recipeId);
  Future<VaultFolderRecipe> addRecipeToFolder(int folderId, int recipeId);
  Future<VaultFolderRecipe> moveRecipe(int folderRecipeId, int targetFolderId);
  Future<void> removeRecipeFromFolder(int folderRecipId);

  // Members
  Future<List<VaultMember>> getMembers(int vaultId);
  Future<VaultMember> addMember(int vaultId, String email);
  Future<void> removeMember(int vaultId, String email);

    
}
