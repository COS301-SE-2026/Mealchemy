import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_confirm_dialog.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_input_dialog.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import '../providers/vault_repository_provider.dart';
import '../models/vault.dart';
import '../models/vault_folder.dart';
import '../providers/vault_provider.dart';

enum _FolderAction { rename, delete }

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
    final currentUserId = ref.watch(authProvider).userId;
    final isOwner = vault.ownerId == currentUserId;

    return PopupMenuButton<_FolderAction>(
      icon: Icon(
        Icons.more_vert,
        color: AppColors.inputBorder.withValues(alpha: 0.95),
      ),
      color: AppColors.bgLight,
      elevation: 4,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      enabled: isOwner,
      onSelected: (action) =>
          _handle(context, ref, action),
      itemBuilder: (context) {
        if (!isOwner) {
          return [
            PopupMenuItem<_FolderAction>(
              enabled: false,
              child: Text(
                'Only the owner can manage folders.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted),
              ),
            ),
          ];
        }
        return [
          PopupMenuItem<_FolderAction>(
            value: _FolderAction.rename,
            child: _row(Icons.drive_file_rename_outline, 'Rename folder'),
          ),
          PopupMenuItem<_FolderAction>(
            value: _FolderAction.delete,
            child: _row(Icons.delete_outline, 'Delete folder',
                destructive: true),
          ),
        ];
      },
    );
  }

  Widget _row(IconData icon, String label, {bool destructive = false}) {
    final color = destructive ? AppColors.error : AppColors.textLight;
    return Row(
      children: [
        Icon(icon, size: 20, color: destructive ? AppColors.error : AppColors.accent),
        const SizedBox(width: 10),
        Text(label, style: AppTextStyles.title.copyWith(color: color)),
      ],
    );
  }

  Future<void> _handle(
      BuildContext context, WidgetRef ref, _FolderAction action) async {
    switch (action) {
      case _FolderAction.rename:
        final name = await showAppInputDialog(
          context: context,
          title: 'Rename Folder',
          label: 'Folder Name',
          hint: folder.folderName,
          initialValue: folder.folderName,
          prefixIcon: Icons.folder_outlined,
        );
        if (name == null) return;
        await ref
            .read(vaultRepositoryProvider)
            .renameFolder(folder.folderId, vault.vaultId, name);
        ref.invalidate(vaultFoldersProvider(vault.vaultId));

      case _FolderAction.delete:
        final ok = await showAppConfirmDialog(
          context: context,
          title: 'Delete Folder',
          message:
              'Delete "${folder.folderName}" and remove its recipes from this folder? This cannot be undone.',
          confirmLabel: 'Delete',
          isDestructive: true,
        );
        if (ok != true) return;
        await ref
            .read(vaultRepositoryProvider)
            .deleteFolder(folder.folderId, vault.vaultId);
        ref.invalidate(vaultFoldersProvider(vault.vaultId));
    }
  }
}