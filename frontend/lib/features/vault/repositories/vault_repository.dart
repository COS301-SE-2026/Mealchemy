<<<<<<< HEAD
import 'package:mealchemy/features/recipe/models/recipe.dart';
import '../models/vault_folder.dart';

abstract class VaultRepository {
  Future<List<VaultFolder>> getFolders();
  Future<VaultFolder> createFolder(String name);

  
  Future<List<Recipe>> getRecipesInFolder(int folderId);
=======
import '../models/vault_folder.dart';
import '../../recipe/models/recipe.dart';

abstract class VaultRepository {
  Future<List<VaultFolder>> getFolders();
  Future<VaultFolder> createFolder(String name);
  Future<List<Recipe>> getRecipesInFolder(int folderId);
>>>>>>> d423b9941270c051a4c9d3eea45e2ad7fcaf0c4f
}