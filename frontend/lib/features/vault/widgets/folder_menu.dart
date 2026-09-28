import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/vault.dart';
import '../models/vault_folder.dart';
import '../providers/vault_folder_management_provider.dart';
import 'vault_folder_actions.dart';

class FolderMenuButton extends ConsumerWidget {
  const FolderMenuButton({
    super.key,
    required this.vault,
    required this.folder,
  });

  final Vault vault;
  final VaultFolder folder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(vaultFolderManagementEnabledProvider(vault));

    return PopupMenuButton<VaultFolderAction>(
      icon: Icon(
        Icons.more_vert,
        color: AppColors.inputBorder.withValues(alpha: 0.95),
      ),
      color: AppColors.bgLight,
      elevation: 4,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabled: enabled,
      tooltip: enabled ? 'Folder actions' : 'Folder changes unavailable',
      onSelected: (action) => showVaultFolderAction(
        context: context,
        ref: ref,
        vault: vault,
        folder: folder,
        action: action,
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: VaultFolderAction.rename,
          child: _row(
            Icons.drive_file_rename_outline,
            'Rename folder',
          ),
        ),
        PopupMenuItem(
          value: VaultFolderAction.delete,
          child: _row(
            Icons.delete_outline,
            'Delete folder',
            destructive: true,
          ),
        ),
      ],
    );
  }

  Widget _row(
    IconData icon,
    String label, {
    bool destructive = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: destructive ? AppColors.error : AppColors.accent,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.title.copyWith(
              color: destructive ? AppColors.error : AppColors.textLight,
            ),
          ),
        ),
      ],
    );
  }
}
