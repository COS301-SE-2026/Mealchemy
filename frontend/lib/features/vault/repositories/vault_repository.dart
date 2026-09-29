import '../models/vault.dart';
import '../models/vault_folder.dart';
import '../models/vault_folder_recipe.dart';
import '../models/vault_invitation.dart';
import '../models/vault_member.dart';

abstract class VaultRepository {
  // Includes owned vaults and vaults the current user has joined.
  Future<List<Vault>> getMyVaults();

  Future<Vault> getVaultById(int vaultId);
  Future<Vault> createVault(String name);
  Future<void> deleteVault(int vaultId);

  // Folders
  Future<List<VaultFolder>> getFolders(int vaultId);
  Future<VaultFolder> createFolder(int vaultId, String folderName);
  Future<VaultFolder> renameFolder(
    int folderId,
    int vaultId,
    String folderName,
  );
  Future<void> deleteFolder(int folderId, int vaultId);

  // Folder-recipe associations
  Future<List<VaultFolderRecipe>> getFolderRecipes(int folderId);
  Future<List<VaultFolderRecipe>> getFoldersForRecipe(int recipeId);
  Future<VaultFolderRecipe> addRecipeToFolder(int folderId, int recipeId);
  Future<VaultFolderRecipe> moveRecipe(
    int folderRecipeId,
    int targetFolderId,
  );
  Future<void> removeRecipeFromFolder(int folderRecipeId);

  // Members
  Future<List<VaultMember>> getMembers(int vaultId);

  // Retained temporarily for the existing menu.
  // Issue 3 replaces that UI flow with createInvitation.
  Future<VaultMember> addMember(int vaultId, String email);

  Future<void> removeMember(int vaultId, int userId);
  Future<VaultMember> changeMemberRole(
    int vaultId,
    int userId,
    VaultMemberRole role,
  );

  // Invitations
  Future<VaultInvitation> createInvitation(int vaultId, String email);
  Future<List<VaultInvitation>> getVaultInvitations(int vaultId);
  Future<List<VaultInvitation>> getMyInvitations();
  Future<VaultMember> acceptInvitation(int invitationId);
  Future<VaultInvitation> declineInvitation(int invitationId);
  Future<void> cancelInvitation(int invitationId);
}
