import 'package:flutter/material.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/vault_folder.dart';
import 'vault_folder_card.dart';

class VaultFolderList extends StatelessWidget {
  const VaultFolderList({
    super.key,
    required this.folders,
  });

  final List<VaultFolder> folders;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PrivateVaultHeader(folderCount: folders.length),
        const SizedBox(height: 16),
        if (folders.isEmpty)
          const _EmptyVaultState()
        else
          ...folders.map((folder) => VaultFolderCard(folder: folder)),
      ],
    );
  }
}

class _PrivateVaultHeader extends StatelessWidget {
  const _PrivateVaultHeader({required this.folderCount});

  final int folderCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Gold accent bar
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        const Icon(
          Icons.lock_outline_rounded,
          color: AppColors.primary,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          'Private Vault',
          style: AppTextStyles.title.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 6),
        const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.primary,
          size: 20,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            '$folderCount FOLDERS',
            style: AppTextStyles.label.copyWith(
              color: AppColors.primary,
              letterSpacing: 1,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyVaultState extends StatelessWidget {
  const _EmptyVaultState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.06),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.folder_open_outlined,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No folders yet',
              style: AppTextStyles.title.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap + to create your first folder',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}