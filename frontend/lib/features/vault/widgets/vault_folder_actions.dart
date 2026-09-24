import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared_widgets/Molecules/app_confirm_dialog.dart';
import '../../../core/shared_widgets/Molecules/app_input_dialog.dart';
import '../models/vault.dart';
import '../models/vault_folder.dart';
import '../providers/shared_vault_access_provider.dart';
import '../providers/vault_folder_management_provider.dart';

Future<void> showVaultFolderAction({
  required BuildContext context,
  required WidgetRef ref,
  required Vault vault,
  required VaultFolderAction action,
  VaultFolder? folder,
}) async {
  if (!ref.read(vaultFolderManagementEnabledProvider(vault))) return;

  final session = ref.read(vaultSessionProvider);
  String? name;

  if (action == VaultFolderAction.delete) {
    if (folder == null) return;

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Delete Folder',
      message: 'Delete "${folder.folderName}" and remove its recipes from this '
          'folder? The recipes themselves will not be deleted. '
          'This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed != true) return;
  } else {
    final creating = action == VaultFolderAction.create;

    if (!creating && folder == null) return;

    name = await showAppInputDialog(
      context: context,
      title: creating ? 'Create Folder' : 'Rename Folder',
      label: 'Folder Name',
      hint: creating ? 'e.g. Weeknight Dinners' : folder!.folderName,
      initialValue: creating ? null : folder!.folderName,
      confirmLabel: creating ? 'Create' : 'Save',
      prefixIcon: Icons.folder_outlined,
    );

    if (name == null) return;
  }

  if (!context.mounted || ref.read(vaultSessionProvider) != session) return;

  final message = await ref
      .read(vaultFolderManagementProvider(vault.vaultId).notifier)
      .submit(
        vault: vault,
        action: action,
        expectedSession: session,
        folder: folder,
        name: name,
      );

  if (!context.mounted ||
      message == null ||
      ref.read(vaultSessionProvider) != session) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
