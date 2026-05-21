import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import '../models/vault_folder.dart';
import '../providers/vault_provider.dart';

class VaultFolderCard extends ConsumerStatefulWidget {
  const VaultFolderCard({
    super.key,
    required this.folder,
  });

  final VaultFolder folder;

  @override
  ConsumerState<VaultFolderCard> createState() => _VaultFolderCardState();
}

class _VaultFolderCardState extends ConsumerState<VaultFolderCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    _isExpanded ? _controller.forward() : _controller.reverse();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync =
        ref.watch(folderRecipeDisplayProvider(widget.folder.folderId));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isExpanded
                ? AppColors.accent.withValues(alpha: 0.5)
                : AppColors.divider,
            width: _isExpanded ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(
                alpha: _isExpanded ? 0.08 : 0.03,
              ),
              blurRadius: _isExpanded ? 16 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Folder header
            InkWell(
              onTap: _toggle,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // Folder icon with gradient
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.12),
                            AppColors.primaryGradientLight.withValues(
                              alpha: 0.06,
                            ),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Icon(
                        _isExpanded
                            ? Icons.folder_open_rounded
                            : Icons.folder_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Name + metadata
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.folder.folderName,
                            style: AppTextStyles.title.copyWith(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          recipesAsync.when(
                            loading: () => Text(
                              'Created ${_formatDate(widget.folder.createdAt)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (recipes) => Text(
                              '${recipes.length} ${recipes.length == 1 ? 'recipe' : 'recipes'}  |  Created ${_formatDate(widget.folder.createdAt)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Chevron
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 260),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _isExpanded
                            ? AppColors.primary
                            : AppColors.textMuted,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expandable recipe list
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                children: [
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.accent.withValues(alpha: 0.2),
                    indent: 16,
                    endIndent: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: recipesAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Unable to load recipes.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                      data: (recipes) => recipes.isEmpty
                          ? _EmptyFolderState()
                          : Column(
                              children: recipes
                                  .map(
                                    (recipe) => _FolderRecipeRow(
                                      recipe: recipe,
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFolderState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 15,
            color: AppColors.accentMuted,
          ),
          const SizedBox(width: 8),
          Text(
            'No recipes in this folder yet.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderRecipeRow extends StatelessWidget {
  const _FolderRecipeRow({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.go('/recipe/${recipe.recipeId}'),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.divider,
            ),
          ),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryGradientLight,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  image: recipe.photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(recipe.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: recipe.photoUrl == null
                    ? const Icon(
                        Icons.restaurant_rounded,
                        color: AppColors.textDark,
                        size: 20,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Recipe info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (recipe.cuisineType != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        recipe.cuisineType!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Match badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 10,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '92% Match',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textDark,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.edit_outlined,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
