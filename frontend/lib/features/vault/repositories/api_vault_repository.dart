import 'package:dio/dio.dart';
import 'vault_repository.dart';
import '../models/vault_folder.dart';
import '../../recipe/models/recipe.dart';

class ApiVaultRepository implements VaultRepository {
  final Dio _dio;

  ApiVaultRepository(this._dio);

  @override
  Future<List<VaultFolder>> getFolders() async {
    final response = await _dio.get('/vault/folders');
    return (response.data as List)
        .map((json) => VaultFolder.fromJson(json))
        .toList();
  }

  @override
  Future<VaultFolder> createFolder(String name) async {
    final response = await _dio.post('/vault/folders', data: {'name': name});
    return VaultFolder.fromJson(response.data);
  }

  @override
  Future<List<Recipe>> getRecipesInFolder(int folderId) async {
    final response = await _dio.get('/vault/folders/$folderId/recipes');
    return (response.data as List)
        .map((json) => Recipe.fromJson(json))
        .toList();
  }
}