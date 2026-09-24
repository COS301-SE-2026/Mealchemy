import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../../external_links/widgets/my_links_folder_row.dart';
import '../../favourites/widgets/my_favs_folder_row.dart';
import '../models/vault.dart';
import '../models/vault_folder.dart';
import '../providers/vault_folder_management_provider.dart';
import 'vault_folder_actions.dart';
import 'vault_folder_row.dart';
import 'vault_menu.dart';

class VaultFolderList extends ConsumerWidget {
  const VaultFolderList({
    super.key,
    required this.vault,
    required this.folders,
  });

  final Vault vault;
  final List<VaultFolder> folders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivate = vault.vaultType == VaultTypes.private;
    final canManageFolders = ref.watch(
      canManageVaultFoldersProvider(vault),
    );
    final enabled = ref.watch(
      vaultFolderManagementEnabledProvider(vault),
    );
    final busy = ref.watch(
      vaultFolderManagementProvider(vault.vaultId),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                vault.name.toUpperCase(),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ),
            VaultMenuButton(vault: vault),
          ],
        ),
        if (busy)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: LinearProgressIndicator(),
          ),
        const SizedBox(height: 8),
        if (folders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No folders in this vault yet.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          )
        else
          for (final folder in folders)
            VaultFolderRow(
              key: ValueKey(folder.folderId),
              vault: vault,
              folder: folder,
            ),
        if (isPrivate) const MyFavsFolderRow(),
        if (isPrivate) const MyLinksFolderRow(),
        if (canManageFolders && folders.length < 3) ...[
          const SizedBox(height: 16),
          AppButton.dashed(
            label: 'ADD MORE FOLDERS',
            onPressed: enabled
                ? () => showVaultFolderAction(
                      context: context,
                      ref: ref,
                      vault: vault,
                      action: VaultFolderAction.create,
                    )
                : null,
            leftIcon: Icons.add,
            isFullWidth: true,
          ),
        ],
      ],
    );
  }
}
