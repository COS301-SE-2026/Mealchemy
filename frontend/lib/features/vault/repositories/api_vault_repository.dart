import 'package:dio/dio.dart';
import 'vault_repository.dart';
import '../models/vault.dart';
import '../models/vault_folder.dart';
import '../models/vault_folder_recipe.dart';
import '../models/vault_member.dart';

class ApiVaultRepository implements VaultRepository {
  final Dio _dio;

  ApiVaultRepository(this._dio);

  // Vaults
  @override
  Future<List<Vault>> getMyVaults() async {
    final response = await _dio.get('/vaults/owner/vaults');
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
  Future<VaultFolderRecipe> addRecipeToFolder( int folderId, int recipeId) async {
    final response = await _dio.post('/recipefolders/folder/$folderId', data: {
      'folderId': folderId,
      'recipeId': recipeId,
    });
    return VaultFolderRecipe.fromJson(response.data);
  }

  @override
  Future<VaultFolderRecipe> moveRecipe( int folderRecipeId, int targetFolderId) async {
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
  Future<void> removeMember(int vaultId, String email) async {
    await _dio.delete('/vault/$vaultId/members/delete', data: {
      'email': email,
    });
  }

  @override
  Future<void> deleteVault(int vaultId) async {
    await _dio.delete('/vaults/$vaultId');
  }
}
