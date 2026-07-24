import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/vault_folder.dart';
import 'vault_folder_row.dart';

//folder section vault name label plus one row per folder
class VaultFolderList extends StatelessWidget {
  const VaultFolderList({
    super.key,
    required this.sectionTitle,
    required this.folders,
  });

  final String sectionTitle;
  final List<VaultFolder> folders;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            sectionTitle.toUpperCase(),
            style: AppTextStyles.label.copyWith(
              color: AppColors.primary,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
        ),
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
              folder: folder, 
              // will add the dialog with  (rename, delete, move recipes add a users)
              onMoreTap: () {},
            ),
      ],
    );
  }
}