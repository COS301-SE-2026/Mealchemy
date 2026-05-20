import 'package:mealchemy/features/recipe/models/recipe.dart';
import '../models/vault_folder.dart';

abstract class VaultRepository {
  Future<List<VaultFolder>> getFolders();
  Future<VaultFolder> createFolder(String name);

  
  Future<List<Recipe>> getRecipesInFolder(int folderId);
}