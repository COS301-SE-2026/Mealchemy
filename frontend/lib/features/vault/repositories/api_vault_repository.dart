import 'package:dio/dio.dart';
import 'vault_repository.dart';
import '../models/vault_folder.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

// Real API implementation calls
class ApiVaultRepository implements VaultRepository {
  final Dio _dio;

  ApiVaultRepository(this._dio);

  @override
  Future<List<VaultFolder>> getFolders() async {
    final response = await _dio.get('/vault/folders');
    final List data = response.data as List;

    return data.map((json) => VaultFolder.fromJson(json)).toList();
  }

  @override
  Future<VaultFolder> createFolder(String name) async {
    final response = await _dio.post('/vault/folders', data: {'name': name});

    return VaultFolder.fromJson(response.data);
  }

  @override
  Future<List<Recipe>> getRecipesInFolder(int folderId) async {
    final response = await _dio.get('/vault/folders/$folderId/recipes');
    final List data = response.data as List;
    
    return data.map((json) => Recipe.fromJson(json)).toList();
  }
}