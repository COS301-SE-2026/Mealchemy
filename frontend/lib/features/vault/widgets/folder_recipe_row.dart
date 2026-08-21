import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_network_image.dart';
import '../../../core/shared_widgets/Molecules/app_confirm_dialog.dart';

//single recipe row inside a vault folder
class FolderRecipeRow extends StatelessWidget {
  const FolderRecipeRow({
    super.key,
    required this.recipe,
    this.onEditTap,
    this.onDeleteConfirmed,
  });

  final Recipe recipe;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteConfirmed;

  String get _subtitle {
    final total = (recipe.prepTimeMins ?? 0) + (recipe.cookingTimeMins ?? 0);
    final parts = <String>[
      if (total > 0) '$total mins',
      if (recipe.cuisineType != null && recipe.cuisineType!.isNotEmpty)
        recipe.cuisineType![0].toUpperCase() + recipe.cuisineType!.substring(1),
    ];
    return parts.join(' · ');
  }

  Future<void> _handleDeleteTap(BuildContext context) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Delete recipe',
      message: 'Are you sure you want to delete this recipe?',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );

    if (confirmed == true) {
      onDeleteConfirmed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => context.push('/recipe/${recipe.recipeId}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _RecipeThumb(photoUrl: recipe.photoUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _handleDeleteTap(context),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),
                    IconButton(
                      onPressed: onEditTap ??
                          () => context.push('/edit-recipe/${recipe.recipeId}'),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//thumbnail with gradient placeholder when there is no photo
class _RecipeThumb extends StatelessWidget {
  const _RecipeThumb({this.photoUrl});

  final String? photoUrl;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 56,
        height: 56,
        child: RecipeNetworkImage(
          photoUrl: photoUrl,
          placeholder: DecoratedBox(
            decoration: const BoxDecoration(gradient: AppColors.brand),
            child: const Icon(
              Icons.restaurant_rounded,
              color: AppColors.textDark,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
