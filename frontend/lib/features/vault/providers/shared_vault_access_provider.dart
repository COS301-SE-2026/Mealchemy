import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/vault.dart';
import '../models/vault_member.dart';
import 'vault_repository_provider.dart';

typedef VaultSession = ({
  int? userId,
  String? token,
  bool restoring,
  bool hasValidCredential,
});

final vaultSessionProvider = Provider<VaultSession>((ref) {
  return ref.watch(
    authProvider.select(
      (state) => (
        userId: state.userId,
        token: state.token,
        restoring: state.isRestoring,
        hasValidCredential: state.isLoggedIn && state.hasValidCredential,
      ),
    ),
  );
});

//separate provider makes connectivity straightforward to override in tests
final vaultConnectionProvider = Provider<NetworkStatus>((ref) {
  return ref.watch(networkStatusProvider);
});

enum SharedVaultAccessFailure {
  checkingSession,
  signInRequired,
  checkingConnection,
  offline,
  unavailable,
}

class SharedVaultAccessException implements Exception {
  const SharedVaultAccessException(this.failure);

  final SharedVaultAccessFailure failure;
}

class SharedVaultAccess {
  SharedVaultAccess({
    required this.vault,
    required this.currentMember,
    required List<VaultMember> members,
  }) : members = List.unmodifiable(members);

  final Vault vault;
  final VaultMember currentMember;
  final List<VaultMember> members;

  VaultMemberRole get role => currentMember.role;

  bool get canManageMembers => role == VaultMemberRole.owner;

  bool get canManageFolders =>
      role == VaultMemberRole.owner || role == VaultMemberRole.editor;
}

final sharedVaultAccessProvider =
    FutureProvider.autoDispose.family<SharedVaultAccess, int>(
  (ref, vaultId) async {
    final session = ref.watch(vaultSessionProvider);
    final connection = ref.watch(vaultConnectionProvider);

    if (session.restoring) {
      throw const SharedVaultAccessException(
        SharedVaultAccessFailure.checkingSession,
      );
    }

    if (session.userId == null ||
        session.token == null ||
        !session.hasValidCredential) {
      throw const SharedVaultAccessException(
        SharedVaultAccessFailure.signInRequired,
      );
    }

    if (connection == NetworkStatus.checking) {
      throw const SharedVaultAccessException(
        SharedVaultAccessFailure.checkingConnection,
      );
    }

    if (connection == NetworkStatus.offline) {
      throw const SharedVaultAccessException(
        SharedVaultAccessFailure.offline,
      );
    }

    if (vaultId <= 0) {
      throw const SharedVaultAccessException(
        SharedVaultAccessFailure.unavailable,
      );
    }

    final repository = ref.watch(vaultRepositoryProvider);

    var disposed = false;
    ref.onDispose(() => disposed = true);

    try {
      final vault = await repository.getVaultById(vaultId);

      //don't start another request for obsolete session
      if (disposed) {
        throw const SharedVaultAccessException(
          SharedVaultAccessFailure.unavailable,
        );
      }

      if (vault.vaultId != vaultId || vault.vaultType != VaultTypes.shared) {
        throw const SharedVaultAccessException(
          SharedVaultAccessFailure.unavailable,
        );
      }

      //getMembers always goes to backend through cache wrapper
      //cached vault metadata alone never grants access
      final members = await repository.getMembers(vaultId);

      final matches = members
          .where(
            (member) =>
                member.vaultId == vaultId && member.userId == session.userId,
          )
          .toList();

      if (matches.length != 1) {
        throw const SharedVaultAccessException(
          SharedVaultAccessFailure.unavailable,
        );
      }

      final currentMember = matches.single;
      final ownsVault = vault.ownerId == session.userId;

      //reject inconsistent owner info rather than granting access
      if (currentMember.isOwner != ownsVault ||
          (currentMember.isOwner && currentMember.id != null)) {
        throw const SharedVaultAccessException(
          SharedVaultAccessFailure.unavailable,
        );
      }

      return SharedVaultAccess(
        vault: vault,
        currentMember: currentMember,
        members: members,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        throw const SharedVaultAccessException(
          SharedVaultAccessFailure.signInRequired,
        );
      }

      if (error.response?.statusCode == 403 ||
          error.response?.statusCode == 404) {
        throw const SharedVaultAccessException(
          SharedVaultAccessFailure.unavailable,
        );
      }

      rethrow;
    }
  },
);

String vaultRoleLabel(VaultMemberRole role) {
  return switch (role) {
    VaultMemberRole.owner => 'Owner',
    VaultMemberRole.editor => 'Editor',
    VaultMemberRole.viewer => 'Viewer',
  };
}

String sharedVaultAccessMessage(Object error) {
  if (error is SharedVaultAccessException) {
    return switch (error.failure) {
      SharedVaultAccessFailure.checkingSession => 'Checking your session…',
      SharedVaultAccessFailure.signInRequired =>
        'Sign in again to view shared-vault members.',
      SharedVaultAccessFailure.checkingConnection =>
        'Checking your connection…',
      SharedVaultAccessFailure.offline =>
        'Connect to the internet to check your role and view members.',
      SharedVaultAccessFailure.unavailable =>
        'This shared vault is unavailable or you no longer have access.',
    };
  }

  return 'Unable to check shared-vault access. Please try again.';
}
