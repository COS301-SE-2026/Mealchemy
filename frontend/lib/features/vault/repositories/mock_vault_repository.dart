import 'vault_repository.dart';
import '../models/vault_folder.dart';
import '../../recipe/models/recipe.dart';

class MockVaultRepository implements VaultRepository {
  // Mock data
  static final List<VaultFolder> _folders = [
    VaultFolder(
      folderId: 1,
      vaultId: 1,
      name: 'Breakfast',
      createdAt: DateTime(2026, 1, 1),
    ),
    VaultFolder(
      folderId: 2,
      vaultId: 1,
      name: 'Dinner',
      createdAt: DateTime(2026, 1, 2),
    ),
  ];

  //Mock recipes for valut display only
  static const List<Recipe> _recipes = [
    Recipe(
      recipeId: 1,
      title: 'Saffron Risotto',
      description: 'A rich and creamy Italian classic',
      cuisineType: 'Italian',
      prepTimeMins: 10,
      cookingTimeMins: 30,
      servingSize: 4,
    ),
    Recipe(
      recipeId: 2,
      title: 'Avocado Kale Superbowl',
      description: 'Fresh and nutritious power bowl',
      cuisineType: 'American',
      prepTimeMins: 15,
      cookingTimeMins: 0,
      servingSize: 1,
    ),
  ];

  @override
  Future<List<VaultFolder>> getFolders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _folders;
  }

  @override
  Future<VaultFolder> createFolder(String name) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return VaultFolder(
      folderId: 99,
      vaultId:  1,
      name: name,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<Recipe>> getRecipesInFolder(int folderId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    //Returns mock recipes for vault display
    return _recipes;
  }
}