import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../models/vault.dart';
import '../models/vault_folder.dart';
import 'shared_vault_access_provider.dart';
import 'vault_provider.dart';
import 'vault_repository_provider.dart';

enum VaultFolderAction { create, rename, delete }

final canManageVaultFoldersProvider =
    Provider.autoDispose.family<bool, Vault>((ref, vault) {
  final session = ref.watch(vaultSessionProvider);

  if (session.restoring ||
      !session.hasValidCredential ||
      session.token == null ||
      session.userId == null) {
    return false;
  }

  if (vault.vaultType != VaultTypes.shared) {
    return vault.ownerId == session.userId;
  }

  final access = ref.watch(sharedVaultAccessProvider(vault.vaultId));

  return !access.isLoading &&
      !access.hasError &&
      access.valueOrNull?.canManageFolders == true;
});

final vaultFolderManagementEnabledProvider =
    Provider.autoDispose.family<bool, Vault>((ref, vault) {
  final allowed = ref.watch(canManageVaultFoldersProvider(vault));
  final online = ref.watch(vaultConnectionProvider) == NetworkStatus.online;
  final busy = ref.watch(vaultFolderManagementProvider(vault.vaultId));

  return allowed && online && !busy;
});

class VaultFolderManagementNotifier extends StateNotifier<bool> {
  VaultFolderManagementNotifier(
    this._ref,
    this._vaultId,
    this._keepAlive,
  ) : super(false);

  final Ref _ref;
  final int _vaultId;
  final void Function() Function() _keepAlive;

  bool _isCurrent(VaultSession session) {
    return mounted && _ref.read(vaultSessionProvider) == session;
  }

  Future<String?> submit({
    required Vault vault,
    required VaultFolderAction action,
    required VaultSession expectedSession,
    VaultFolder? folder,
    String? name,
  }) async {
    if (!mounted || state || !_isCurrent(expectedSession)) {
      return null;
    }

    if (vault.vaultId != _vaultId ||
        (action != VaultFolderAction.create &&
            (folder == null || folder.vaultId != _vaultId))) {
      return 'This folder does not belong to the selected vault.';
    }

    final trimmedName = name?.trim() ?? '';

    if (action != VaultFolderAction.delete && trimmedName.isEmpty) {
      return 'Enter a folder name.';
    }

    final allowed = _ref.read(canManageVaultFoldersProvider(vault));
    final online = _ref.read(vaultConnectionProvider) == NetworkStatus.online;

    if (!allowed || !online) {
      return 'Connect to the internet and check your folder permissions.';
    }

    final repository = _ref.read(vaultRepositoryProvider);
    final release = _keepAlive();

    state = true;

    try {
      if (vault.vaultType == VaultTypes.shared) {
        //owner may have changed user's role while a dialog was open
        _ref.invalidate(sharedVaultAccessProvider(_vaultId));

        final access = await _ref.read(
          sharedVaultAccessProvider(_vaultId).future,
        );

        if (!_isCurrent(expectedSession)) return null;

        if (!access.canManageFolders) {
          return 'Only the vault Owner or an Editor can manage folders.';
        }
      }

      if (!_isCurrent(expectedSession)) return null;

      if (_ref.read(vaultConnectionProvider) != NetworkStatus.online) {
        return 'Connect to the internet before changing folders.';
      }

      VaultFolder? updated;

      switch (action) {
        case VaultFolderAction.create:
          updated = await repository.createFolder(_vaultId, trimmedName);

        case VaultFolderAction.rename:
          updated = await repository.renameFolder(
            folder!.folderId,
            _vaultId,
            trimmedName,
          );

        case VaultFolderAction.delete:
          await repository.deleteFolder(folder!.folderId, _vaultId);
      }

      if (updated != null &&
          (updated.vaultId != _vaultId ||
              (action == VaultFolderAction.rename &&
                  updated.folderId != folder!.folderId))) {
        throw const FormatException('Unexpected folder response.');
      }

      if (!_isCurrent(expectedSession)) return null;

      _refresh(vault, folder);

      return switch (action) {
        VaultFolderAction.create => 'Folder created.',
        VaultFolderAction.rename => 'Folder renamed.',
        VaultFolderAction.delete =>
          'Folder deleted. The recipes are preserved.',
      };
    } catch (error) {
      if (!_isCurrent(expectedSession)) return null;

      //timeout may occur after backend saved the change
      _refresh(vault, folder);

      if (vault.vaultType == VaultTypes.shared) {
        _ref.invalidate(sharedVaultAccessProvider(_vaultId));
      }

      return vaultFolderErrorMessage(error);
    } finally {
      if (mounted) state = false;
      release();
    }
  }

  void _refresh(Vault vault, VaultFolder? folder) {
    //Vault search also updates because it watches these providers
    _ref.invalidate(vaultFoldersProvider(_vaultId));

    if (vault.vaultType == VaultTypes.private) {
      _ref.invalidate(privateFoldersProvider);
    }

    if (folder != null) {
      _ref.invalidate(folderRecipesProvider(folder.folderId));
    }
  }
}

final vaultFolderManagementProvider = StateNotifierProvider.autoDispose
    .family<VaultFolderManagementNotifier, bool, int>((ref, vaultId) {
  ref.watch(vaultSessionProvider);

  return VaultFolderManagementNotifier(
    ref,
    vaultId,
    () {
      final link = ref.keepAlive();
      return link.close;
    },
  );
});

String vaultFolderErrorMessage(Object error) {
  if (error is SharedVaultAccessException) {
    return 'Your shared-vault access could not be verified. Refresh the vault.';
  }

  if (error is DioException) {
    switch (error.response?.statusCode) {
      case 401:
        return 'Sign in again to manage folders.';
      case 403:
        return 'You no longer have permission to manage these folders.';
      case 404:
        return 'This vault or folder is no longer available.';
      case 409:
        return 'This folder changed or the name is already in use. '
            'Refresh and try again.';
    }

    final body = error.response?.data;

    if (body is Map && body['message'] is String) {
      final message = (body['message'] as String).trim();
      if (message.isNotEmpty) return message;
    }
  }

  return 'We could not confirm the change. Check the refreshed folders '
      'before trying again.';
}
