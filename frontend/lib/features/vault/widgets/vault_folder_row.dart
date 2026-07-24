import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/vault_folder.dart';
import '../providers/vault_provider.dart';
import 'folder_recipe_row.dart';

//folder row that expands in place to reveal its recipes
class VaultFolderRow extends ConsumerStatefulWidget {
  const VaultFolderRow({
    super.key,
    required this.folder,
    this.onMoreTap,
  });

  final VaultFolder folder;
  final VoidCallback? onMoreTap;

  @override
  ConsumerState<VaultFolderRow> createState() => _VaultFolderRowState();
}

class _VaultFolderRowState extends ConsumerState<VaultFolderRow> {
  bool _isExpanded = false;

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync =
        ref.watch(folderRecipeDisplayProvider(widget.folder.folderId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  _FolderAvatar(isOpen: _isExpanded),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.folder.folderName,
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
                            'Created ${_formatDate(widget.folder.createdAt)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.tertiaryMuted,
                              fontSize: 13,
                            ),
                          ),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (recipes) => Text(
                            '${recipes.length} ${recipes.length == 1 ? 'recipe' : 'recipes'} · Created ${_formatDate(widget.folder.createdAt)}',
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
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onMoreTap,
                    icon: Icon(
                      Icons.more_vert,
                      color: AppColors.inputBorder.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        //expanded contents
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: recipesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Unable to load recipes.',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.error),
                ),
              ),
              data: (recipes) => recipes.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No recipes in this folder yet.',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textMuted),
                      ),
                    )
                  : Column(
                      children: [
                        for (final recipe in recipes)
                          FolderRecipeRow(recipe: recipe),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

//leading rounded-square folder avatar
class _FolderAvatar extends StatelessWidget {
  const _FolderAvatar({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isOpen ? Icons.folder_open_rounded : Icons.folder_rounded,
        color: AppColors.accent,
        size: 24,
      ),
    );
  }
}