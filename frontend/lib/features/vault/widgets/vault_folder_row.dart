import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/vault_folder.dart';
import '../providers/vault_provider.dart';

class VaultFolderRow extends ConsumerWidget {
  const VaultFolderRow({
    super.key,
    required this.folder,
    this.onTap,
    this.onMoreTap,
  });

  final VaultFolder folder;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync =
        ref.watch(folderRecipeDisplayProvider(folder.folderId));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              const _FolderAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder.folderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.textLight,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    recipesAsync.when(
                      loading: () => Text(
                        'Created ${_formatDate(folder.createdAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.tertiaryMuted,
                          fontSize: 13,
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (recipes) => Text(
                        '${recipes.length} ${recipes.length == 1 ? 'recipe' : 'recipes'} · Created ${_formatDate(folder.createdAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.tertiaryMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onMoreTap,
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.inputBorder.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _FolderAvatar extends StatelessWidget {
  const _FolderAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.folder_rounded,
        color: AppColors.accent,
        size: 24,
      ),
    );
  }
}