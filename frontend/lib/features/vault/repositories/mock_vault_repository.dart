import '../models/vault.dart';
import '../models/vault_folder.dart';
import '../models/vault_folder_recipe.dart';
import '../models/vault_member.dart';
import 'vault_repository.dart';

class MockVaultRepository implements VaultRepository {
  static const int _mockUserId = 1;

  final List<Vault> _vaults = [
    Vault(
      vaultId: 1,
      ownerId: _mockUserId,
      vaultType: VaultTypes.private,
      name: 'My Vault',
      createdAt: DateTime.parse('2026-07-01T08:00:00Z'),
    ),
    Vault(
      vaultId: 2,
      ownerId: _mockUserId,
      vaultType: VaultTypes.shared,
      name: 'Family',
      createdAt: DateTime.parse('2026-07-10T10:00:00Z'),
    ),
  ];

  final List<VaultFolder> _folders = [
    VaultFolder(
      folderId: 1,
      vaultId: 1,
      folderName: 'General',
      createdAt: DateTime.parse('2026-07-01T08:00:00Z'),
    ),
    VaultFolder(
      folderId: 2,
      vaultId: 1,
      folderName: 'Weeknight Dinners',
      createdAt: DateTime.parse('2026-07-05T17:30:00Z'),
    ),
    VaultFolder(
      folderId: 3,
      vaultId: 2,
      folderName: 'General',
      createdAt: DateTime.parse('2026-07-10T10:01:00Z'),
    ),
  ];

  final List<VaultFolderRecipe> _folderRecipes = [
    VaultFolderRecipe(id: 1, folderId: 1, recipeId: 1, addedAt: DateTime.parse('2026-07-01T08:05:00Z'), addedByUserId: _mockUserId),
    VaultFolderRecipe(id: 2, folderId: 1, recipeId: 2, addedAt: DateTime.parse('2026-07-01T08:05:00Z'), addedByUserId: _mockUserId),
    VaultFolderRecipe(id: 3, folderId: 2, recipeId: 1, addedAt: DateTime.parse('2026-07-05T17:32:00Z'), addedByUserId: _mockUserId),
    VaultFolderRecipe(id: 4, folderId: 3, recipeId: 2, addedAt: DateTime.parse('2026-07-10T10:05:00Z'), addedByUserId: _mockUserId),
  ];

  final List<VaultMember> _members = [];

  int _nextVaultId = 3;
  int _nextFolderId = 4;
  int _nextFolderRecipeId = 5;
  int _nextMemberId = 1;

  Future<void> _networkDelay() =>
      Future.delayed(const Duration(milliseconds: 400));

  @override
  Future<List<Vault>> getMyVaults() async {
    await _networkDelay();
    return _vaults.where((v) => v.ownerId == _mockUserId).toList();
  }

  @override
  Future<Vault> getVaultById(int vaultId) async {
    await _networkDelay();
    try {
      return _vaults.firstWhere((v) => v.vaultId == vaultId);
    } catch (_) {
      throw StateError('Vault not found.');
    }
  }

  @override
  Future<Vault> createVault(String name) async {
    await _networkDelay();
    final vault = Vault(
      vaultId: _nextVaultId++,
      ownerId: _mockUserId,
      vaultType: VaultTypes.shared,
      name: name,
      createdAt: DateTime.now().toUtc(),
    );
    _vaults.add(vault);
    return vault;
  }

  @override
  Future<List<VaultFolder>> getFolders(int vaultId) async {
    await _networkDelay();
    if (!_vaults.any((v) => v.vaultId == vaultId)) {
      throw StateError('Vault not found.');
    }
    return _folders.where((f) => f.vaultId == vaultId).toList();
  }

  @override
  Future<VaultFolder> createFolder(int vaultId, String folderName) async {
    await _networkDelay();
    if (!_vaults.any((v) => v.vaultId == vaultId)) {
      throw StateError('Vault not found.');
    }
    final folder = VaultFolder(
      folderId: _nextFolderId++,
      vaultId: vaultId,
      folderName: folderName,
      createdAt: DateTime.now().toUtc(),
    );
    _folders.add(folder);
    return folder;
  }

  @override
  Future<VaultFolder> renameFolder(
      int folderId, int vaultId, String folderName) async {
    await _networkDelay();
    final index = _folders.indexWhere((f) => f.folderId == folderId);
    if (index == -1) throw StateError('Folder not found.');
    final updated = VaultFolder(
      folderId: folderId,
      vaultId: vaultId,
      folderName: folderName,
      createdAt: _folders[index].createdAt,
    );
    _folders[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteFolder(int folderId, int vaultId) async {
    await _networkDelay();
    _folders.removeWhere((f) => f.folderId == folderId);
    _folderRecipes.removeWhere((fr) => fr.folderId == folderId);
  }

  @override
  Future<List<VaultFolderRecipe>> getFolderRecipes(int folderId) async {
    await _networkDelay();
    if (!_folders.any((f) => f.folderId == folderId)) {
      throw StateError('Folder not found.');
    }
    return _folderRecipes.where((fr) => fr.folderId == folderId).toList();
  }

  @override
  Future<List<VaultFolderRecipe>> getFoldersForRecipe(int recipeId) async {
    await _networkDelay();
    return _folderRecipes.where((fr) => fr.recipeId == recipeId).toList();
  }

  @override
  Future<VaultFolderRecipe> addRecipeToFolder(int folderId, int recipeId) async {
    await _networkDelay();
    if (!_folders.any((f) => f.folderId == folderId)) {
      throw StateError('Folder not found.');
    }
    final record = VaultFolderRecipe(
      id: _nextFolderRecipeId++,
      folderId: folderId,
      recipeId: recipeId,
      addedAt: DateTime.now().toUtc(),
      addedByUserId: _mockUserId,
    );
    _folderRecipes.add(record);
    return record;
  }

  @override
  Future<VaultFolderRecipe> moveRecipe(
      int folderRecipeId, int targetFolderId) async {
    await _networkDelay();
    final index = _folderRecipes.indexWhere((fr) => fr.id == folderRecipeId);
    if (index == -1) throw StateError('No record found');

    final currentFolder = _folders.firstWhere(
      (f) => f.folderId == _folderRecipes[index].folderId,
      orElse: () => throw StateError('Folder not found.'),
    );
    final targetFolder = _folders.firstWhere(
      (f) => f.folderId == targetFolderId,
      orElse: () => throw StateError('New folder not found.'),
    );

    if (currentFolder.vaultId != targetFolder.vaultId) {
      throw StateError('Recipes can only moved between folders in the same vault.');
    }

    final moved = VaultFolderRecipe(
      id: folderRecipeId,
      folderId: targetFolderId,
      recipeId: _folderRecipes[index].recipeId,
      addedAt: _folderRecipes[index].addedAt,
      addedByUserId: _folderRecipes[index].addedByUserId,
    );
    _folderRecipes[index] = moved;
    return moved;
  }

  @override
  Future<void> removeRecipeFromFolder(int folderRecipeId) async {
    await _networkDelay();
    _folderRecipes.removeWhere((fr) => fr.id == folderRecipeId);
  }

  @override
  Future<List<VaultMember>> getMembers(int vaultId) async {
    await _networkDelay();
    if (!_vaults.any((v) => v.vaultId == vaultId)) {
      throw StateError('Vault not found.');
    }
    return _members.where((m) => m.vaultId == vaultId).toList();
  }

  @override
  Future<VaultMember> addMember(int vaultId, String email) async {
    await _networkDelay();
    if (!_vaults.any((v) => v.vaultId == vaultId)) {
      throw StateError('Vault not found.');
    }
    final member = VaultMember(
      id: _nextMemberId++,
      vaultId: vaultId,
      userId: 100 + _nextMemberId,
      joinedAt: DateTime.now().toUtc(),
    );
    _members.add(member);
    return member;
  }

  @override
  Future<void> removeMember(int vaultId, String email) async {
    await _networkDelay();
    final index = _members.lastIndexWhere((m) => m.vaultId == vaultId);
    if (index != -1) _members.removeAt(index);
  }

  @override
  Future<void> deleteVault(int vaultId) async {
    await _networkDelay();
    _vaults.removeWhere((v) => v.vaultId == vaultId);
    final folderIds = _folders
        .where((f) => f.vaultId == vaultId)
        .map((f) => f.folderId)
        .toList();
    _folders.removeWhere((f) => f.vaultId == vaultId);
    _folderRecipes.removeWhere((fr) => folderIds.contains(fr.folderId));
    _members.removeWhere((m) => m.vaultId == vaultId);
  }
}