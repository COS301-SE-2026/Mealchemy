import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/vault/models/vault_invitation.dart';

Map<String, dynamic> _json({
  String status = 'PENDING',
  String? respondedAt,
}) =>
    {
      'invitationId': 12,
      'vaultId': 5,
      'vaultName': 'Flat 3B Meals',
      'invitedEmail': 'sofia@example.com',
      'invitedByEmail': 'gabriela@example.com',
      'status': status,
      'createdAt': '2020-01-01T10:00:00Z',
      'expiresAt': '2020-01-08T10:00:00Z',
      'respondedAt': respondedAt,
    };

void main() {
  test('parses the backend invitation response', () {
    final invite = VaultInvitation.fromJson(_json());

    expect(invite.invitationId, 12);
    expect(invite.vaultId, 5);
    expect(invite.vaultName, 'Flat 3B Meals');
    expect(invite.invitedEmail, 'sofia@example.com');
    expect(invite.invitedByEmail, 'gabriela@example.com');
    expect(invite.respondedAt, isNull);
    expect(invite.expiresAt, DateTime.utc(2020, 1, 8, 10));
  });

  test('past expiresAt does not override backend PENDING status', () {
    final invite = VaultInvitation.fromJson(_json());

    expect(invite.isPending, isTrue);
  });

  test('parses every documented invitation status', () {
    for (final status in VaultInvitationStatus.values) {
      final invite = VaultInvitation.fromJson(
        _json(status: status.apiValue),
      );

      expect(invite.status, status);
      expect(invite.isPending, status == VaultInvitationStatus.pending);
    }
  });

  test('parses response time', () {
    final invite = VaultInvitation.fromJson(
      _json(
        status: 'ACCEPTED',
        respondedAt: '2020-01-02T12:30:00Z',
      ),
    );

    expect(invite.respondedAt, DateTime.utc(2020, 1, 2, 12, 30));
  });

  test('rejects unknown status', () {
    expect(
      () => VaultInvitation.fromJson(_json(status: 'UNKNOWN')),
      throwsA(isA<FormatException>()),
    );
  });
}
