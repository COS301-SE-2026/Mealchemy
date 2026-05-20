import '../models/vault_folder.dart';
import '../../recipe/models/recipe.dart';

abstract class VaultRepository {
  Future<List<VaultFolder>> getFolders();
  Future<VaultFolder> createFolder(String name);
  Future<List<Recipe>> getRecipesInFolder(int folderId);
}