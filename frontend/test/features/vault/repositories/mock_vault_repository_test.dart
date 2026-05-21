import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/vault/repositories/mock_vault_repository.dart';

void main() {
  late MockVaultRepository repo;

  setUp(() {
    repo = MockVaultRepository();
  });

  // ── Vaults ──────────────────────────────────────────────────────────────

  group('MockVaultRepository.getVaultsByOwnerId', () {
    test('returns vaults for a matching owner', () async {
      final vaults = await repo.getVaultsByOwnerId(1);
      expect(vaults, hasLength(1));
      expect(vaults.first.name, 'My Vault');
    });

    test('returns empty list when owner has no vaults', () async {
      final vaults = await repo.getVaultsByOwnerId(999);
      expect(vaults, isEmpty);
    });
  });

  group('MockVaultRepository.getVaultById', () {
    test('returns the correct vault', () async {
      final vault = await repo.getVaultById(1);
      expect(vault.vaultId, 1);
      expect(vault.name, 'My Vault');
    });
  });

  group('MockVaultRepository.createVault', () {
    test('returns a new vault with the provided values', () async {
      final vault = await repo.createVault(1, 'PRIVATE', 'New Vault');
      expect(vault.name, 'New Vault');
      expect(vault.ownerId, 1);
      expect(vault.vaultType, 'PRIVATE');
    });
  });

  group('MockVaultRepository.updateVault', () {
    test('returns vault with updated name', () async {
      final vault = await repo.updateVault(1, 1, 'PRIVATE', 'Updated Vault');
      expect(vault.vaultId, 1);
      expect(vault.name, 'Updated Vault');
    });
  });

  group('MockVaultRepository.deleteVault', () {
    test('completes without error', () async {
      await expectLater(repo.deleteVault(1), completes);
    });
  });

  // ── Folders ──────────────────────────────────────────────────────────────

  group('MockVaultRepository.getFoldersByVaultId', () {
    test('returns folders for a matching vault', () async {
      final folders = await repo.getFoldersByVaultId(1);
      expect(folders, hasLength(2));
      expect(folders.map((f) => f.folderName), containsAll(['Breakfast', 'Dinner']));
    });

    test('returns empty list when vault has no folders', () async {
      final folders = await repo.getFoldersByVaultId(999);
      expect(folders, isEmpty);
    });
  });

  group('MockVaultRepository.getFolderByName', () {
    test('returns the correct folder', () async {
      final folder = await repo.getFolderByName('Breakfast');
      expect(folder.folderId, 1);
      expect(folder.folderName, 'Breakfast');
    });
  });

  group('MockVaultRepository.getFolderById', () {
    test('returns the correct folder', () async {
      final folder = await repo.getFolderById(1);
      expect(folder.folderId, 1);
      expect(folder.folderName, 'Breakfast');
    });
  });

  group('MockVaultRepository.createFolder', () {
    test('returns a new folder with the provided values', () async {
      final folder = await repo.createFolder(1, 'Lunch');
      expect(folder.folderName, 'Lunch');
      expect(folder.vaultId, 1);
    });
  });

  group('MockVaultRepository.updateFolder', () {
    test('returns folder with updated name', () async {
      final folder = await repo.updateFolder(1, 1, 'Brunch');
      expect(folder.folderId, 1);
      expect(folder.folderName, 'Brunch');
    });
  });

  group('MockVaultRepository.deleteFolder', () {
    test('completes without error', () async {
      await expectLater(repo.deleteFolder(1), completes);
    });
  });

  // ── Folder recipes ────────────────────────────────────────────────────────

  group('MockVaultRepository.getRecipesByFolderId', () {
    test('returns folder recipes for a matching folder', () async {
      final recipes = await repo.getRecipesByFolderId(1);
      expect(recipes, hasLength(2));
    });

    test('returns empty list when folder has no recipes', () async {
      final recipes = await repo.getRecipesByFolderId(999);
      expect(recipes, isEmpty);
    });
  });

  group('MockVaultRepository.getFoldersByRecipeId', () {
    test('returns folder recipes for a matching recipe', () async {
      final entries = await repo.getFoldersByRecipeId(1);
      expect(entries, hasLength(1));
      expect(entries.first.recipeId, 1);
    });
  });

  group('MockVaultRepository.getFolderRecipeById', () {
    test('returns the correct entry', () async {
      final entry = await repo.getFolderRecipeById(1);
      expect(entry.id, 1);
    });
  });

  group('MockVaultRepository.createFolderRecipe', () {
    test('returns a new entry with the provided values', () async {
      final entry = await repo.createFolderRecipe(1, 3);
      expect(entry.folderId, 1);
      expect(entry.recipeId, 3);
    });
  });

  group('MockVaultRepository.updateFolderRecipe', () {
    test('returns updated entry', () async {
      final entry = await repo.updateFolderRecipe(1, 1, 3);
      expect(entry.id, 1);
      expect(entry.recipeId, 3);
    });
  });

  group('MockVaultRepository.deleteFolderRecipe', () {
    test('completes without error', () async {
      await expectLater(repo.deleteFolderRecipe(1), completes);
    });
  });
}
