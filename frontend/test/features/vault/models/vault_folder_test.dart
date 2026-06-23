import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/vault/models/vault_folder.dart';

void main() {
  group('VaultFolder', () {
    //Testing  fromJson create correct model
    test('creates VaultFolder from json', () {
      final folder = VaultFolder.fromJson({
        'folder_id': 1,
        'vault_id': 1,
        'name': 'Breakfast',
        'created_at': '2026-01-01T00:00:00.000',
      });
      expect(folder.folderId, 1);
       expect(folder.vaultId, 1);
      expect(folder.name, 'Breakfast');
    });

    //Testing fromJson parses date 
    test('parses createdAt date correctly', ( ) {
      final folder = VaultFolder.fromJson({
        'folder_id': 2,
        'vault_id': 1,
        'name': 'Dinner',
        'created_at': '2026-06-15T00:00:00.000',
      });
      expect(folder.createdAt.year, 2026);
      expect(folder.createdAt.month, 6);
      expect(folder.createdAt.day, 15);
    });

    // Testing VaultFolder  constructor set fields correctly
    test('constructor sets all fields correctly', () {
      final folder = VaultFolder(
        folderId: 3,
        vaultId: 2,
        name: 'Lunch',
        createdAt: DateTime(2026, 1, 1),
      );  
      expect(folder.folderId, 3);
      expect(folder.vaultId, 2);
      expect(folder.name, 'Lunch');
    });
  });
}