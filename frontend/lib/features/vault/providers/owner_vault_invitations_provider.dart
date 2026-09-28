import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../models/vault_invitation.dart';
import 'shared_vault_access_provider.dart';
import 'vault_repository_provider.dart';

final ownerVaultInvitationsProvider =
    FutureProvider.autoDispose.family<List<VaultInvitation>, int>(
  (ref, vaultId) async {
    ref.watch(vaultSessionProvider);
    final repository = ref.watch(vaultRepositoryProvider);
    final accessFuture = ref.watch(sharedVaultAccessProvider(vaultId).future);

    var disposed = false;
    ref.onDispose(() => disposed = true);

    final access = await accessFuture;

    if (disposed || !access.canManageMembers) {
      throw const SharedVaultAccessException(
        SharedVaultAccessFailure.unavailable,
      );
    }

    final invitations = await repository.getVaultInvitations(vaultId);

    if (invitations.any((invite) => invite.vaultId != vaultId)) {
      throw const FormatException('Unexpected vault in invitation response.');
    }

    final sorted = [...invitations]..sort((a, b) {
        final byDate = b.createdAt.compareTo(a.createdAt);
        return byDate != 0 ? byDate : b.invitationId.compareTo(a.invitationId);
      });

    return List.unmodifiable(sorted);
  },
);

final ownerVaultInvitationsEnabledProvider =
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

class OwnerVaultInvitationOperation {
  const OwnerVaultInvitationOperation({
    this.isSending = false,
    this.cancellingId,
    this.emailError,
    this.message,
    this.isError = false,
  });

  final bool isSending;
  final int? cancellingId;
  final String? emailError;
  final String? message;
  final bool isError;

  bool get isBusy => isSending || cancellingId != null;
}

class OwnerVaultInvitationsNotifier
    extends StateNotifier<OwnerVaultInvitationOperation> {
  OwnerVaultInvitationsNotifier(
    this._ref,
    this._vaultId,
    this._keepAlive,
  ) : super(const OwnerVaultInvitationOperation());

  final Ref _ref;
  final int _vaultId;
  final void Function() Function() _keepAlive;

  void clearFeedback() {
    if (state.isBusy) return;
    state = const OwnerVaultInvitationOperation();
  }

  bool _canAct(VaultSession expectedSession) {
    if (state.isBusy) return false;

    if (_ref.read(vaultSessionProvider) != expectedSession ||
        !_ref.read(ownerVaultInvitationsEnabledProvider(_vaultId))) {
      state = const OwnerVaultInvitationOperation(
        message: 'An online connection and current vault-owner access '
            'are required.',
        isError: true,
      );
      return false;
    }

    return true;
  }

  Future<bool> send({
    required String email,
    required VaultSession expectedSession,
  }) async {
    if (!_canAct(expectedSession)) return false;

    final trimmed = email.trim();

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed)) {
      state = const OwnerVaultInvitationOperation(
        emailError: 'Enter a valid email address.',
        isError: true,
      );
      return false;
    }

    final access = _ref.read(sharedVaultAccessProvider(_vaultId)).requireValue;

    if (trimmed.toLowerCase() ==
        access.currentMember.email.trim().toLowerCase()) {
      state = const OwnerVaultInvitationOperation(
        emailError: 'You cannot invite yourself.',
        isError: true,
      );
      return false;
    }

    final repository = _ref.read(vaultRepositoryProvider);

    return _run(
      expectedSession: expectedSession,
      sending: true,
      action: () async {
        final invitation = await repository.createInvitation(
          _vaultId,
          trimmed,
        );

        if (invitation.vaultId != _vaultId || !invitation.isPending) {
          throw const FormatException('Unexpected invitation response.');
        }
      },
      successMessage: 'Invitation sent to $trimmed.',
    );
  }

  Future<bool> cancel({
    required VaultInvitation invitation,
    required VaultSession expectedSession,
  }) async {
    if (!_canAct(expectedSession)) return false;

    final history = _ref.read(ownerVaultInvitationsProvider(_vaultId));
    final current = history.valueOrNull;

    final isStillPending = invitation.vaultId == _vaultId &&
        invitation.isPending &&
        !history.isLoading &&
        !history.hasError &&
        current != null &&
        current.any(
          (item) =>
              item.invitationId == invitation.invitationId &&
              item.vaultId == _vaultId &&
              item.isPending,
        );

    if (!isStillPending) {
      state = const OwnerVaultInvitationOperation(
        message: 'This invitation changed. Refresh the list and try again.',
        isError: true,
      );
      _ref.invalidate(ownerVaultInvitationsProvider(_vaultId));
      return false;
    }

    final repository = _ref.read(vaultRepositoryProvider);

    return _run(
      expectedSession: expectedSession,
      cancellingId: invitation.invitationId,
      action: () => repository.cancelInvitation(invitation.invitationId),
      successMessage: 'Invitation cancelled.',
    );
  }

  Future<bool> _run({
    required VaultSession expectedSession,
    required Future<void> Function() action,
    required String successMessage,
    bool sending = false,
    int? cancellingId,
  }) async {
    final release = _keepAlive();

    state = OwnerVaultInvitationOperation(
      isSending: sending,
      cancellingId: cancellingId,
    );

    try {
      await action();

      if (!mounted || _ref.read(vaultSessionProvider) != expectedSession) {
        return false;
      }

      state = OwnerVaultInvitationOperation(message: successMessage);
      _ref.invalidate(ownerVaultInvitationsProvider(_vaultId));
      return true;
    } catch (error) {
      if (!mounted || _ref.read(vaultSessionProvider) != expectedSession) {
        return false;
      }

      state = OwnerVaultInvitationOperation(
        message: ownerInvitationErrorMessage(error, mutation: true),
        isError: true,
      );

      //invite may have been accepted/cancelled elsewhere
      _ref.invalidate(ownerVaultInvitationsProvider(_vaultId));

      if (error is DioException &&
          (error.response?.statusCode == 401 ||
              error.response?.statusCode == 403)) {
        _ref.invalidate(sharedVaultAccessProvider(_vaultId));
      }

      return false;
    } finally {
      release();
    }
  }
}

final ownerVaultInvitationOperationProvider = StateNotifierProvider.autoDispose
    .family<OwnerVaultInvitationsNotifier, OwnerVaultInvitationOperation, int>(
  (ref, vaultId) {
    ref.watch(vaultSessionProvider);

    return OwnerVaultInvitationsNotifier(
      ref,
      vaultId,
      () {
        final link = ref.keepAlive();
        return link.close;
      },
    );
  },
);

String ownerInvitationErrorMessage(
  Object error, {
  bool mutation = false,
}) {
  if (error is SharedVaultAccessException) {
    return sharedVaultAccessMessage(error);
  }

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
        return 'Check the invitation details and try again.';
      case 401:
        return 'Sign in again to manage invitations.';
      case 403:
        return 'Only the vault owner can manage invitations.';
      case 404:
        return 'The requested user, vault, or invitation was not found.';
      case 409:
        return 'The user is already a member, has a pending invitation, '
            'or this invitation has already been handled.';
    }
  }

  return mutation
      ? 'We could not confirm the change. Refresh invitation history '
          'before trying again.'
      : 'Unable to load invitations. Please try again.';
}

String vaultInvitationStatusLabel(VaultInvitationStatus status) {
  return switch (status) {
    VaultInvitationStatus.pending => 'Pending',
    VaultInvitationStatus.accepted => 'Accepted',
    VaultInvitationStatus.declined => 'Declined',
    VaultInvitationStatus.cancelled => 'Cancelled',
    VaultInvitationStatus.expired => 'Expired',
  };
}
