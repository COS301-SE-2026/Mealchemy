import 'package:dio/dio.dart';
import 'vault_repository.dart';
import '../models/vault.dart';
import '../models/vault_folder.dart';
import '../models/vault_folder_recipe.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

class ApiVaultRepository implements VaultRepository {
  final Dio _dio;

  ApiVaultRepository(this._dio);

  // Vaults
  @override
  Future<List<Vault>> getVaultsByOwnerId(int ownerId) async {
    final response = await _dio.get('/vaults/owner/$ownerId');
    return (response.data as List).map((json) => Vault.fromJson(json)).toList();
  }

  @override
  Future<Vault> getVaultById(int id) async {
    final response = await _dio.get('/vaults/$id');
    return Vault.fromJson(response.data);
  }

  @override
  Future<Vault> createVault(int ownerId, String vaultType, String name) async {
    final response = await _dio.post('/vaults', data: {
      'ownerId': ownerId,
      'vaultType': vaultType,
      'name': name,
    });
    return Vault.fromJson(response.data);
  }

  @override
  Future<Vault> updateVault(
      int id, int ownerId, String vaultType, String name) async {
    final response = await _dio.put('/vaults/$id', data: {
      'ownerId': ownerId,
      'vaultType': vaultType,
      'name': name,
    });
    return Vault.fromJson(response.data);
  }

  @override
  Future<void> deleteVault(int id) async {
    await _dio.delete('/vaults/$id');
  }

  // Folders
  @override
  Future<List<VaultFolder>> getFoldersByVaultId(int vaultId) async {
    final response = await _dio.get('/folders/vault/$vaultId');
    return (response.data as List)
        .map((json) => VaultFolder.fromJson(json))
        .toList();
  }

  @override
  Future<VaultFolder> getFolderByName(String name) async {
    final response = await _dio.get('/folders/folder/name/$name');
    return VaultFolder.fromJson(response.data);
  }

  @override
  Future<VaultFolder> getFolderById(int id) async {
    final response = await _dio.get('/folders/folder/$id');
    return VaultFolder.fromJson(response.data);
  }

  @override
  Future<VaultFolder> createFolder(int vaultId, String folderName) async {
    final response = await _dio.post('/folders', data: {
      'vaultId': vaultId,
      'folderName': folderName,
    });
    return VaultFolder.fromJson(response.data);
  }

  @override
  Future<VaultFolder> updateFolder(
      int id, int vaultId, String folderName) async {
    final response = await _dio.put('/folders/$id', data: {
      'vaultId': vaultId,
      'folderName': folderName,
    });
    return VaultFolder.fromJson(response.data);
  }

  @override
  Future<void> deleteFolder(int id) async {
    await _dio.delete('/folders/$id');
  }

  // Folder Recipes
  @override
  Future<List<VaultFolderRecipe>> getRecipesByFolderId(int folderId) async {
    final response = await _dio.get('/recipefolders/recipes/$folderId');
    return (response.data as List)
        .map((json) => VaultFolderRecipe.fromJson(json))
        .toList();
  }

  @override
  Future<List<VaultFolderRecipe>> getFoldersByRecipeId(int recipeId) async {
    final response = await _dio.get('/recipefolders/folders/$recipeId');
    return (response.data as List)
        .map((json) => VaultFolderRecipe.fromJson(json))
        .toList();
  }

  @override
  Future<VaultFolderRecipe> getFolderRecipeById(int id) async {
    final response = await _dio.get('/recipefolders/$id');
    return VaultFolderRecipe.fromJson(response.data);
  }

  @override
  Future<VaultFolderRecipe> createFolderRecipe(
      int folderId, int recipeId) async {
    final response = await _dio.post('/recipefolders', data: {
      'folderId': folderId,
      'recipeId': recipeId,
    });
    return VaultFolderRecipe.fromJson(response.data);
  }

  @override
  Future<VaultFolderRecipe> updateFolderRecipe(
      int id, int folderId, int recipeId) async {
    final response = await _dio.put('/recipefolders/$id', data: {
      'folderId': folderId,
      'recipeId': recipeId,
    });
    return VaultFolderRecipe.fromJson(response.data);
  }

  @override
  Future<void> deleteFolderRecipe(int id) async {
    await _dio.delete('/recipefolders/$id');
  }
}