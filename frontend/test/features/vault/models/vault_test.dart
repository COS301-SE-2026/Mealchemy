import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/vault/models/vault.dart';

void main() {
  group('VaultTypes', () {
    // Testing the enum-like constants match the backend serialization (uppercase)
    test('constants are the uppercase backend values', () {
      expect(VaultTypes.private, 'PRIVATE');
      expect(VaultTypes.shared, 'SHARED');
      expect(VaultTypes.global, 'GLOBAL');
    });
  });

  group('Vault', () {
    //Testing fromJson creates the correct model
    test('creates Vault from json', () {
      final vault = Vault.fromJson({
        'vaultId': 1,
        'ownerId': 42,
        'vaultType': 'PRIVATE',
        'name': 'My Vault',
        'createdAt': '2026-01-01T00:00:00.000',
      });
      expect(vault.vaultId, 1);
      expect(vault.ownerId, 42);
      expect(vault.vaultType, VaultTypes.private);
      expect(vault.name, 'My Vault');
    });

    //Testing fromJson keeps owner Id null when the key is absent
    test('leaves ownerId null when missing', () {
      final vault = Vault.fromJson({
        'vaultId': 2,
        'vaultType': 'GLOBAL',
        'name': 'Global Vault',
        'createdAt': '2026-01-01T00:00:00.000',
      });
      expect(vault.ownerId, isNull);
      expect(vault.vaultType, VaultTypes.global);
    });

    //Testing fromJson  parses the date
    test('parses createdAt date correctly', () {
      final vault = Vault.fromJson({
        'vaultId': 3,
        'ownerId': 7,
        'vaultType': 'SHARED',
        'name': 'Team Vault',
        'createdAt': '2026-06-15T00:00:00.000',
      });
      expect(vault.createdAt.year, 2026);
      expect(vault.createdAt.month, 6);
      expect(vault.createdAt.day, 15);
    });

    //Testing  the constructor sets field correctly
    test('constructor sets all fields correctly', () {
      final vault = Vault(
        vaultId: 4,
        ownerId: 9,
        vaultType: VaultTypes.private,
        name: 'Personal',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(vault.vaultId, 4);
      expect(vault.ownerId, 9);
      expect(vault.vaultType, VaultTypes.private);
      expect(vault.name, 'Personal');
    });
  });
}
