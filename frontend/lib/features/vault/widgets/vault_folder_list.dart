import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/vault.dart';
import '../models/vault_folder.dart';
import 'vault_menu.dart';
import 'vault_folder_row.dart';

//folder section vault name label plus one row per folder
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
      ],
    );
  }
}