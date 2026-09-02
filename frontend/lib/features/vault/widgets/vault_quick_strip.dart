import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_network_image.dart';

class VaultQuickStrip extends StatelessWidget {
  const VaultQuickStrip({
    super.key,
    required this.recipes,
  });

  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recipes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return _QuickRecipeThumbnail(recipe: recipes[index]);
        },
      ),
    );
  }
}

class _QuickRecipeThumbnail extends StatelessWidget {
  const _QuickRecipeThumbnail({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/recipe/${recipe.recipeId}'),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryGradientLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            foregroundDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accent,
                width: 2,
              ),
            ),
            child: RecipeNetworkImage(
              photoUrl: recipe.photoUrl,
              placeholder: const Center(
                child: Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.textDark,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 64,
            child: Text(
              recipe.title,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textLight,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
