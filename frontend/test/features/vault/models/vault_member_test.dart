import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/vault/models/vault_member.dart';

Map<String, dynamic> _json({
  int? id = 5,
  String role = 'VIEWER',
}) =>
    {
      'id': id,
      'vaultId': 2,
      'userId': 7,
      'email': 'chef@example.com',
      'joinedAt': '2026-09-21T10:05:00Z',
      'role': role,
    };

void main() {
  test('parses member identity, email, date and role', () {
    final member = VaultMember.fromJson(_json());

    expect(member.id, 5);
    expect(member.vaultId, 2);
    expect(member.userId, 7);
    expect(member.email, 'chef@example.com');
    expect(member.joinedAt, DateTime.utc(2026, 9, 21, 10, 5));
    expect(member.role, VaultMemberRole.viewer);
    expect(member.isOwner, isFalse);
  });

  test('accepts the synthetic owner with a null membership ID', () {
    final owner = VaultMember.fromJson(_json(id: null, role: 'OWNER'));

    expect(owner.id, isNull);
    expect(owner.userId, 7);
    expect(owner.isOwner, isTrue);
  });

  test('parses every documented role', () {
    for (final role in VaultMemberRole.values) {
      final member = VaultMember.fromJson(_json(role: role.apiValue));
      expect(member.role, role);
    }
  });

  test('unknown roles are rejected', () {
    expect(
      () => VaultMember.fromJson(_json(role: 'SUPER_EDITOR')),
      throwsA(isA<FormatException>()),
    );
  });

  test('changing a role preserves member identity', () {
    final original = VaultMember.fromJson(_json());
    final updated = original.copyWithRole(VaultMemberRole.editor);

    expect(updated.role, VaultMemberRole.editor);
    expect(updated.id, original.id);
    expect(updated.userId, original.userId);
    expect(updated.email, original.email);
    expect(original.role, VaultMemberRole.viewer);
  });
}
