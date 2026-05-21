import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/vault/models/vault_folder_recipe.dart';

void main() {
  group('VaultFolderRecipe', () {
    test('constructor sets all fields correctly', () {
      final entry = VaultFolderRecipe(
        id: 1,
        folderId: 2,
        recipeId: 3,
        addedAt: DateTime(2026, 1, 1),
      );
      expect(entry.id, 1);
      expect(entry.folderId, 2);
      expect(entry.recipeId, 3);
    });

    test('fromJson creates correct VaultFolderRecipe', () {
      final entry = VaultFolderRecipe.fromJson({
        'id': 1,
        'folderId': 2,
        'recipeId': 3,
        'addedAt': '2026-01-01T00:00:00.000',
      });
      expect(entry.id, 1);
      expect(entry.folderId, 2);
      expect(entry.recipeId, 3);
    });

    test('fromJson parses addedAt correctly', () {
      final entry = VaultFolderRecipe.fromJson({
        'id': 1,
        'folderId': 1,
        'recipeId': 1,
        'addedAt': '2026-06-15T00:00:00.000',
      });
      expect(entry.addedAt.year, 2026);
      expect(entry.addedAt.month, 6);
      expect(entry.addedAt.day, 15);
    });
  });
}
