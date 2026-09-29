import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../models/vault_invitation.dart';
import '../models/vault_member.dart';
import 'shared_vault_access_provider.dart';
import 'vault_provider.dart';
import 'vault_repository_provider.dart';

final incomingInvitationsUnavailableProvider = Provider<String?>((ref) {
  final session = ref.watch(vaultSessionProvider);

  if (session.restoring) {
    return 'Checking your session…';
  }

  if (session.userId == null ||
      session.token == null ||
      !session.hasValidCredential) {
    return 'Sign in again to view your invitations.';
  }

  return switch (ref.watch(vaultConnectionProvider)) {
    NetworkStatus.checking => 'Checking your connection…',
    NetworkStatus.offline =>
      'Connect to the internet to view and respond to invitations.',
    NetworkStatus.online => null,
  };
});

final incomingVaultInvitationsProvider =
    FutureProvider.autoDispose<List<VaultInvitation>>((ref) async {
  ref.watch(vaultSessionProvider);

  final unavailable = ref.watch(incomingInvitationsUnavailableProvider);
  if (unavailable != null) throw StateError(unavailable);

  final invitations =
      await ref.watch(vaultRepositoryProvider).getMyInvitations();

  //follow server's status, not expiresAt timestamp
  final pending = invitations.where((invite) => invite.isPending).toList()
    ..sort((a, b) {
      final byDate = b.createdAt.compareTo(a.createdAt);
      return byDate != 0 ? byDate : b.invitationId.compareTo(a.invitationId);
    });

  return List.unmodifiable(pending);
});

class IncomingInvitationOperation {
  const IncomingInvitationOperation({
    this.invitationId,
    this.isAccepting = false,
    this.message,
    this.isError = false,
    this.joinedVaultId,
  });

  final int? invitationId;
  final bool isAccepting;
  final String? message;
  final bool isError;
  final int? joinedVaultId;

  bool get isBusy => invitationId != null;
}

class IncomingVaultInvitationsNotifier
    extends StateNotifier<IncomingInvitationOperation> {
  IncomingVaultInvitationsNotifier(this._ref, this._keepAlive)
      : super(const IncomingInvitationOperation());

  final Ref _ref;
  final void Function() Function() _keepAlive;

  final Set<int> _completedIds = {};

  Future<bool> respond({
    required VaultInvitation invitation,
    required bool accept,
    required VaultSession expectedSession,
  }) async {
    if (state.isBusy || _completedIds.contains(invitation.invitationId)) {
      return false;
    }

    if (_ref.read(vaultSessionProvider) != expectedSession) {
      state = const IncomingInvitationOperation(
        message: 'Your session changed. Refresh your invitations.',
        isError: true,
      );
      return false;
    }

    final unavailable = _ref.read(incomingInvitationsUnavailableProvider);
    if (unavailable != null) {
      state = IncomingInvitationOperation(
        message: unavailable,
        isError: true,
      );
      return false;
    }

    final history = _ref.read(incomingVaultInvitationsProvider);
    final invitations = history.valueOrNull;

    final available = invitation.isPending &&
        !history.isLoading &&
        !history.hasError &&
        invitations != null &&
        invitations.any(
          (item) =>
              item.invitationId == invitation.invitationId &&
              item.vaultId == invitation.vaultId &&
              item.isPending,
        );

    if (!available) {
      state = const IncomingInvitationOperation(
        message: 'This invitation changed. Refresh the list and try again.',
        isError: true,
      );
      _ref.invalidate(incomingVaultInvitationsProvider);
      return false;
    }

    final repository = _ref.read(vaultRepositoryProvider);
    final release = _keepAlive();

    state = IncomingInvitationOperation(
      invitationId: invitation.invitationId,
      isAccepting: accept,
    );

    try {
      if (accept) {
        final member = await repository.acceptInvitation(
          invitation.invitationId,
        );

        if (member.vaultId != invitation.vaultId ||
            member.userId != expectedSession.userId ||
            member.role != VaultMemberRole.viewer) {
          throw const FormatException(
            'Unexpected membership response after accepting invitation.',
          );
        }
      } else {
        final result = await repository.declineInvitation(
          invitation.invitationId,
        );

        if (result.invitationId != invitation.invitationId ||
            result.vaultId != invitation.vaultId ||
            result.status != VaultInvitationStatus.declined) {
          throw const FormatException(
            'Unexpected response after declining invitation.',
          );
        }
      }

      if (!mounted || _ref.read(vaultSessionProvider) != expectedSession) {
        return false;
      }

      _completedIds.add(invitation.invitationId);

      state = IncomingInvitationOperation(
        message: accept
            ? 'You joined ${invitation.vaultName} as a Viewer.'
            : 'Invitation declined.',
        joinedVaultId: accept ? invitation.vaultId : null,
      );

      _ref.invalidate(incomingVaultInvitationsProvider);

      if (accept) {
        _refreshVault(invitation.vaultId);
      }

      return true;
    } catch (error) {
      if (!mounted || _ref.read(vaultSessionProvider) != expectedSession) {
        return false;
      }

      state = IncomingInvitationOperation(
        message: incomingInvitationErrorMessage(error, mutation: true),
        isError: true,
      );

      _ref.invalidate(incomingVaultInvitationsProvider);

      //timeout can occur after backend completed acceptance
      //refresh membership-related data without claiming success
      if (accept) {
        _refreshVault(invitation.vaultId);
      }

      return false;
    } finally {
      release();
    }
  }

  void _refreshVault(int vaultId) {
    _ref.invalidate(vaultsProvider);
    _ref.invalidate(vaultMembersProvider(vaultId));
    _ref.invalidate(sharedVaultAccessProvider(vaultId));
    _ref.invalidate(vaultFoldersProvider(vaultId));
  }
}

final incomingVaultInvitationOperationProvider =
    StateNotifierProvider.autoDispose<IncomingVaultInvitationsNotifier,
        IncomingInvitationOperation>((ref) {
  ref.watch(vaultSessionProvider);

  return IncomingVaultInvitationsNotifier(
    ref,
    () {
      final link = ref.keepAlive();
      return link.close;
    },
  );
});

String incomingInvitationErrorMessage(
  Object error, {
  bool mutation = false,
}) {
  if (error is DioException) {
    final body = error.response?.data;

    if (body is Map) {
      final message = body['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    switch (error.response?.statusCode) {
      case 401:
        return 'Sign in again to respond to invitations.';
      case 403:
        return 'This invitation is not available to your account.';
      case 404:
        return 'This invitation is no longer available.';
      case 409:
        return 'This invitation has already been handled. '
            'Your invitation list has been refreshed.';
    }
  }

  return mutation
      ? 'We could not confirm the response. Refresh your invitations '
          'and vaults before trying again.'
      : 'Unable to load your invitations. Please try again.';
}
