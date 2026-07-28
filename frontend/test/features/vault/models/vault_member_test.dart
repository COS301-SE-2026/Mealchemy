import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/vault/models/vault_member.dart';

void main() {
  group('VaultMember', () {
    // Testing fromJson creates the correct model
    test('creates VaultMember from json', () {
      final member = VaultMember.fromJson({
        'id': 5,
        'vaultId': 1,
        'userId': 42,
        'joinedAt': '2026-01-01T00:00:00.000',
      });
      expect(member.id, 5);
      expect(member.vaultId, 1);
      expect(member.userId, 42);
    });

    //Testing fromJson  parses the date
    test('parses joinedAt date correctly', () {
      final member = VaultMember.fromJson({
        'id': 6,
        'vaultId': 1,
        'userId': 7,
        'joinedAt': '2026-06-15T00:00:00.000',
      });
      expect(member.joinedAt.year, 2026);
      expect(member.joinedAt.month, 6);
      expect(member.joinedAt.day, 15);
    });

    //Testing the constructor set  fields correctl
    test('constructor sets all fields correctly', () {
      final member = VaultMember(
        id: 3,
        vaultId: 2,
        userId: 9,
        joinedAt: DateTime(2026, 1, 1),
      );
      expect(member.id, 3);
      expect(member.vaultId, 2);
      expect(member.userId, 9);
    });
  });
}