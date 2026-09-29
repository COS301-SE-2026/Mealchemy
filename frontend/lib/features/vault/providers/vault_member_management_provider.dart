import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../models/vault_member.dart';
import 'shared_vault_access_provider.dart';
import 'vault_provider.dart';
import 'vault_repository_provider.dart';

enum VaultMemberAction {
  makeEditor,
  makeViewer,
  remove,
}

class VaultMemberManagementState {
  const VaultMemberManagementState({
    this.userId,
    this.action,
    this.message,
    this.isError = false,
  });

  final int? userId;
  final VaultMemberAction? action;
  final String? message;
  final bool isError;

  bool get isBusy => userId != null;
}

final vaultMemberManagementEnabledProvider =
    Provider.autoDispose.family<bool, int>((ref, vaultId) {
  final session = ref.watch(vaultSessionProvider);
  final access = ref.watch(sharedVaultAccessProvider(vaultId));

  return session.userId != null &&
      session.token != null &&
      session.hasValidCredential &&
      !session.restoring &&
      ref.watch(vaultConnectionProvider) == NetworkStatus.online &&
      !access.isLoading &&
      !access.hasError &&
      access.valueOrNull?.canManageMembers == true;
});

class VaultMemberManagementNotifier
    extends StateNotifier<VaultMemberManagementState> {
  VaultMemberManagementNotifier(
    this._ref,
    this._vaultId,
    this._keepAlive,
  ) : super(const VaultMemberManagementState());

  final Ref _ref;
  final int _vaultId;
  final void Function() Function() _keepAlive;

  Future<bool> submit({
    required VaultMember member,
    required VaultMemberAction action,
    required VaultSession expectedSession,
  }) async {
    if (state.isBusy) return false;

    if (_ref.read(vaultSessionProvider) != expectedSession ||
        !_ref.read(vaultMemberManagementEnabledProvider(_vaultId))) {
      state = const VaultMemberManagementState(
        message: 'An online connection and current vault-owner access '
            'are required.',
        isError: true,
      );
      return false;
    }

    final access = _ref.read(sharedVaultAccessProvider(_vaultId)).requireValue;

    if (member.vaultId != _vaultId ||
        member.id == null ||
        member.isOwner ||
        member.userId == access.vault.ownerId ||
        member.userId == expectedSession.userId) {
      state = const VaultMemberManagementState(
        message: 'The vault owner cannot be changed or removed here.',
        isError: true,
      );
      return false;
    }

    final matches = access.members
        .where(
          (current) =>
              current.vaultId == _vaultId && current.userId == member.userId,
        )
        .toList();

    if (matches.length != 1 ||
        matches.single.id != member.id ||
        matches.single.role != member.role ||
        matches.single.email != member.email ||
        matches.single.isOwner) {
      state = const VaultMemberManagementState(
        message: 'This member changed. Review the refreshed list '
            'before trying again.',
        isError: true,
      );
      _refreshMembers();
      return false;
    }

    final targetRole = switch (action) {
      VaultMemberAction.makeEditor => VaultMemberRole.editor,
      VaultMemberAction.makeViewer => VaultMemberRole.viewer,
      VaultMemberAction.remove => null,
    };

    if (targetRole == member.role) {
      state = VaultMemberManagementState(
        message: 'This member is already a ${vaultRoleLabel(member.role)}.',
      );
      return false;
    }

    final repository = _ref.read(vaultRepositoryProvider);
    final release = _keepAlive();

    state = VaultMemberManagementState(
      userId: member.userId,
      action: action,
    );

    try {
      if (action == VaultMemberAction.remove) {
        await repository.removeMember(_vaultId, member.userId);
      } else {
        final updated = await repository.changeMemberRole(
          _vaultId,
          member.userId,
          targetRole!,
        );

        if (updated.vaultId != _vaultId ||
            updated.userId != member.userId ||
            updated.id != member.id ||
            updated.role != targetRole) {
          throw const FormatException('Unexpected member update response.');
        }
      }

      if (!mounted || _ref.read(vaultSessionProvider) != expectedSession) {
        return false;
      }

      state = VaultMemberManagementState(
        message: action == VaultMemberAction.remove
            ? '${member.email} was removed from this vault.'
            : '${member.email} now has the ${vaultRoleLabel(targetRole!)} role.',
      );

      _refreshMembers();
      return true;
    } catch (error) {
      if (!mounted || _ref.read(vaultSessionProvider) != expectedSession) {
        return false;
      }

      state = VaultMemberManagementState(
        message: vaultMemberManagementErrorMessage(error),
        isError: true,
      );

      //refresh after failures too - member may have changed elsewhere or the backend may have completed a request before a timeout
      _refreshMembers();
      return false;
    } finally {
      release();
    }
  }

  void _refreshMembers() {
    _ref.invalidate(vaultMembersProvider(_vaultId));
    _ref.invalidate(sharedVaultAccessProvider(_vaultId));
  }
}

final vaultMemberManagementProvider = StateNotifierProvider.autoDispose
    .family<VaultMemberManagementNotifier, VaultMemberManagementState, int>(
  (ref, vaultId) {
    ref.watch(vaultSessionProvider);

    return VaultMemberManagementNotifier(
      ref,
      vaultId,
      () {
        final link = ref.keepAlive();
        return link.close;
      },
    );
  },
);

String vaultMemberManagementErrorMessage(Object error) {
  if (error is DioException) {
    final body = error.response?.data;

    if (body is Map) {
      final message = body['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    switch (error.response?.statusCode) {
      case 400:
        return 'This role change is not allowed.';
      case 401:
        return 'Sign in again to manage members.';
      case 403:
        return 'Only the vault owner can manage members.';
      case 404:
        return 'The vault or member is no longer available.';
      case 409:
        return 'This member changed. Review the refreshed list and try again.';
    }
  }

  return 'We could not confirm the change. Check the refreshed member list '
      'before trying again.';
}
