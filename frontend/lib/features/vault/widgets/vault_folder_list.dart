import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/Molecules/app_input_dialog.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/vault.dart';
import '../models/vault_folder.dart';
import 'vault_menu.dart';
import 'vault_folder_row.dart';
import '../providers/vault_repository_provider.dart';   
import '../providers/vault_provider.dart';               

//folder section vault name label plus one row per folder
class VaultFolderList extends ConsumerWidget {
  const VaultFolderList({
    super.key,
    required this.vault,
    required this.folders,
  });

  final Vault vault;
  final List<VaultFolder> folders;

  Future<void> _createFolder(BuildContext context, WidgetRef ref) async {
    final name = await showAppInputDialog(
      context: context,
      title: 'Create Folder',
      label: 'Folder Name',
      hint: 'e.g. Weeknight Dinners',
      confirmLabel: 'Create',
      prefixIcon: Icons.folder_outlined,
    );
    if (name == null) return;
    await ref.read(vaultRepositoryProvider).createFolder(vault.vaultId, name);
    ref.invalidate(vaultFoldersProvider(vault.vaultId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              vault.name.toUpperCase(),
              style: AppTextStyles.label.copyWith(
                color: AppColors.primary,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            VaultMenuButton(vault: vault),
          ],
        ),
        const SizedBox(height: 8),
        if (folders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No folders in this vault yet.',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
          )
        else
          for (final folder in folders)
            VaultFolderRow(
              vault: vault,
              folder: folder,
            ),
        if (folders.length < 3) ...[
          const SizedBox(height: 16),
          AppButton.dashed(
            label: 'ADD MORE FOLDERS',
            onPressed: () => _createFolder(context, ref),
            leftIcon: Icons.add,
            isFullWidth: true,
          ),
        ],
      ],
    );
  }
}
