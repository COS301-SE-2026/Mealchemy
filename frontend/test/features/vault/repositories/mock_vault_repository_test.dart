import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/vault/models/vault_invitation.dart';
import 'package:mealchemy/features/vault/models/vault_member.dart';
import 'package:mealchemy/features/vault/repositories/mock_vault_repository.dart';

void main() {
  late MockVaultRepository repository;

  setUp(() {
    repository = MockVaultRepository();
  });

  test('owner appears with nullable membership ID', () async {
    final members = await repository.getMembers(2);

    expect(members.single.role, VaultMemberRole.owner);
    expect(members.single.id, isNull);
    expect(members.single.email, 'sofia@example.com');
  });

  test('accepting an invitation adds its vault and grants Viewer', () async {
    final invitation = (await repository.getMyInvitations()).single;

    expect(
      (await repository.getMyVaults())
          .any((vault) => vault.vaultId == invitation.vaultId),
      isFalse,
    );

    final member = await repository.acceptInvitation(
      invitation.invitationId,
    );

    expect(member.role, VaultMemberRole.viewer);
    expect(await repository.getMyInvitations(), isEmpty);
    expect(
      (await repository.getMyVaults())
          .any((vault) => vault.vaultId == invitation.vaultId),
      isTrue,
    );

    await expectLater(
      repository.acceptInvitation(invitation.invitationId),
      throwsStateError,
    );
  });

  test('declining an invitation does not grant vault access', () async {
    final invitation = (await repository.getMyInvitations()).single;

    final declined = await repository.declineInvitation(
      invitation.invitationId,
    );

    expect(declined.status, VaultInvitationStatus.declined);
    expect(declined.respondedAt, isNotNull);
    expect(await repository.getMyInvitations(), isEmpty);
    expect(
      (await repository.getMyVaults())
          .any((vault) => vault.vaultId == invitation.vaultId),
      isFalse,
    );
  });

  test('cancellation remains visible in owner invitation history', () async {
    final invitation = await repository.createInvitation(
      2,
      'chef@example.com',
    );

    await repository.cancelInvitation(invitation.invitationId);

    final history = await repository.getVaultInvitations(2);
    expect(history.single.status, VaultInvitationStatus.cancelled);
    expect(history.single.respondedAt, isNotNull);

    // A cancelled invitation does not prevent a fresh invitation.
    final replacement = await repository.createInvitation(
      2,
      'chef@example.com',
    );
    expect(replacement.isPending, isTrue);
  });

  test('duplicate pending invitation is rejected', () async {
    await repository.createInvitation(2, 'chef@example.com');

    await expectLater(
      repository.createInvitation(2, 'chef@example.com'),
      throwsStateError,
    );
  });

  test('owner changes role and removes the selected member by user ID',
      () async {
    final first = await repository.addMember(2, 'gabriela@example.com');
    final second = await repository.addMember(2, 'chef@example.com');

    final promoted = await repository.changeMemberRole(
      2,
      first.userId,
      VaultMemberRole.editor,
    );

    expect(promoted.role, VaultMemberRole.editor);

    await repository.removeMember(2, first.userId);

    final members = await repository.getMembers(2);
    expect(members.any((member) => member.userId == first.userId), isFalse);
    expect(members.any((member) => member.userId == second.userId), isTrue);
    expect(members.any((member) => member.isOwner), isTrue);
  });
}
