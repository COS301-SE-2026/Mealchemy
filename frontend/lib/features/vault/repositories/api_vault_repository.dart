import 'package:dio/dio.dart';
import 'vault_repository.dart';
import '../models/vault.dart';
import '../models/vault_folder.dart';
import '../models/vault_folder_recipe.dart';
import '../models/vault_member.dart';
import '../models/vault_invitation.dart';

class ApiVaultRepository implements VaultRepository {
  final Dio _dio;

  ApiVaultRepository(this._dio);

  // Vaults
  @override
  Future<List<Vault>> getMyVaults() async {
    final response = await _dio.get('/vaults/accessible');
    return (response.data as List).map((json) => Vault.fromJson(json)).toList();
  }

  @override
  Future<Vault> getVaultById(int vaultId) async {
    final response = await _dio.get('/vaults/$vaultId');
    return Vault.fromJson(response.data);
  }

  @override
  Future<Vault> createVault(String name) async {
    final response = await _dio.post('/vaults', data: {
      'vaultType': VaultTypes.shared,
      'name': name,
    });
    return Vault.fromJson(response.data);
  }

//Folders
  @override
  Future<List<VaultFolder>> getFolders(int vaultId) async {
    final response = await _dio.get('/folders/vault/$vaultId');
    return (response.data as List)
        .map((json) => VaultFolder.fromJson(json))
        .toList();
  }

  // Folders
  @override
  Future<VaultFolder> createFolder(int vaultId, String folderName) async {
    final response = await _dio.post('/folders', data: {
      'vaultId': vaultId,
      'folderName': folderName,
    });
    return VaultFolder.fromJson(response.data);
  }

  @override
  Future<VaultFolder> renameFolder(
      int folderId, int vaultId, String folderName) async {
    final response = await _dio.put('/folders/$folderId', data: {
      'vaultId': vaultId,
      'folderName': folderName,
    });
    return VaultFolder.fromJson(response.data);
  }

  @override
  Future<void> deleteFolder(int folderId, int vaultId) async {
    await _dio.delete('/folders/vault/$vaultId/folder/$folderId');
  }

  // Folder Recipes
  @override
  Future<List<VaultFolderRecipe>> getFolderRecipes(int folderId) async {
    final response = await _dio.get('/recipefolders/recipes/$folderId');
    return (response.data as List)
        .map((json) => VaultFolderRecipe.fromJson(json))
        .toList();
  }

  @override
  Future<List<VaultFolderRecipe>> getFoldersForRecipe(int recipeId) async {
    final response = await _dio.get('/recipefolders/folders/$recipeId');
    return (response.data as List)
        .map((json) => VaultFolderRecipe.fromJson(json))
        .toList();
  }

  @override
  Future<VaultFolderRecipe> addRecipeToFolder(
      int folderId, int recipeId) async {
    final response = await _dio.post('/recipefolders/folder/$folderId', data: {
      'folderId': folderId,
      'recipeId': recipeId,
    });
    return VaultFolderRecipe.fromJson(response.data);
  }

  @override
  Future<VaultFolderRecipe> moveRecipe(
      int folderRecipeId, int targetFolderId) async {
    final response = await _dio.put('/recipefolders/$folderRecipeId', data: {
      'folderId': targetFolderId,
    });
    return VaultFolderRecipe.fromJson(response.data);
  }

  @override
  Future<void> removeRecipeFromFolder(int folderRecipeId) async {
    await _dio.delete('/recipefolders/$folderRecipeId');
  }

  // Members
  @override
  Future<List<VaultMember>> getMembers(int vaultId) async {
    final response = await _dio.get('/vault/$vaultId/members/all');
    return (response.data as List)
        .map((json) => VaultMember.fromJson(json))
        .toList();
  }

  @override
  Future<VaultMember> addMember(int vaultId, String email) async {
    final response = await _dio.post('/vault/$vaultId/members/create', data: {
      'email': email,
    });
    return VaultMember.fromJson(response.data);
  }

  @override
  Future<void> removeMember(int vaultId, int userId) async {
    await _dio.delete('/vault/$vaultId/members/$userId');
  }

  @override
  Future<void> deleteVault(int vaultId) async {
    await _dio.delete('/vaults/$vaultId');
  }

  @override
  Future<VaultMember> changeMemberRole(
    int vaultId,
    int userId,
    VaultMemberRole role,
  ) async {
    if (role == VaultMemberRole.owner) {
      throw ArgumentError('OWNER cannot be assigned to a member.');
    }

    final response = await _dio.patch<dynamic>(
      '/vault/$vaultId/members/$userId/role',
      data: {'role': role.apiValue},
    );

    return VaultMember.fromJson(_responseObject(response));
  }

  @override
  Future<VaultInvitation> createInvitation(
    int vaultId,
    String email,
  ) async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      throw ArgumentError('An email address is required.');
    }

    final response = await _dio.post<dynamic>(
      '/vault/$vaultId/invitations',
      data: {'email': trimmedEmail},
    );

    return VaultInvitation.fromJson(_responseObject(response));
  }

  @override
  Future<List<VaultInvitation>> getVaultInvitations(int vaultId) async {
    final response = await _dio.get<dynamic>(
      '/vault/$vaultId/invitations',
    );

    return _invitationList(response);
  }

  @override
  Future<List<VaultInvitation>> getMyInvitations() async {
    final response = await _dio.get<dynamic>('/invitations/me');
    return _invitationList(response);
  }

  @override
  Future<VaultMember> acceptInvitation(int invitationId) async {
    final response = await _dio.post<dynamic>(
      '/invitations/$invitationId/accept',
    );

    return VaultMember.fromJson(_responseObject(response));
  }

  @override
  Future<VaultInvitation> declineInvitation(int invitationId) async {
    final response = await _dio.post<dynamic>(
      '/invitations/$invitationId/decline',
    );

    return VaultInvitation.fromJson(_responseObject(response));
  }

  @override
  Future<void> cancelInvitation(int invitationId) async {
    await _dio.delete('/invitations/$invitationId');
  }

  Map<String, dynamic> _responseObject(Response<dynamic> response) {
    return Map<String, dynamic>.from(response.data as Map);
  }

  List<VaultInvitation> _invitationList(Response<dynamic> response) {
    return (response.data as List)
        .map(
          (item) => VaultInvitation.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }
}
