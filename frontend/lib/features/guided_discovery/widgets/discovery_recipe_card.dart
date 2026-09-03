import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/recommendation.dart';

// Swipe card recipe photo, match badge, title, cuisine/time, and a pantry hint
class DiscoveryRecipeCard extends StatelessWidget {
  const DiscoveryRecipeCard({
    super.key,
    required this.recommendation,
    required this.currentIndex,
    required this.totalRecipes,
    this.onViewRecipe,
  });

  final Recommendation recommendation;
  final int currentIndex;
  final int totalRecipes;
  final VoidCallback? onViewRecipe;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth.clamp(300.0, 402.0);
        final cardHeight = constraints.maxHeight.clamp(360.0, 520.0);

        return SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.accentMuted.withValues(alpha: 0.45),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _CardImage(url: recommendation.recipe.photoUrl),
                      Positioned(
                        left: 14,
                        top: 14,
                        child: _MatchBadge(
                          matchPercentage: recommendation.matchPercent,
                        ),
                      ),
                    ],
                  ),
                ),
                _RecipeInfo(
                  recommendation: recommendation,
                  currentIndex: currentIndex,
                  totalRecipes: totalRecipes,
                  onViewRecipe: onViewRecipe,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: const Icon(Icons.restaurant, color: AppColors.textMuted, size: 42),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return Image.network(
      url!,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}

class _RecipeInfo extends StatelessWidget {
  const _RecipeInfo({
    required this.recommendation,
    required this.currentIndex,
    required this.totalRecipes,
    required this.onViewRecipe,
  });

  final Recommendation recommendation;
  final int currentIndex;
  final int totalRecipes;
  final VoidCallback? onViewRecipe;

  @override
  Widget build(BuildContext context) {
    final recipe = recommendation.recipe;
    final totalTime =
        (recipe.prepTimeMins ?? 0) + (recipe.cookingTimeMins ?? 0);

    return Container(
      color: AppColors.surfaceLight,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 13),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.primary,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
          if (recipe.cuisineType != null)
            Text(
              _titleCase(recipe.cuisineType!),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.tertiaryMuted,
                fontSize: 12,
              ),
            ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 9),
          _PantryHint(
            gapCount: recommendation.pantryGapCount,
            missing: recommendation.missingIngredients,
          ),
          const SizedBox(height: 9),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 9),
          Row(
            children: [
              const Icon(Icons.schedule, size: 15, color: AppColors.primary),
              const SizedBox(width: 5),
              Text(
                '${totalTime}m',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 16),
              _CardDots(
                currentIndex: currentIndex,
                totalRecipes: totalRecipes,
              ),
              const Spacer(),
              InkWell(
                onTap: onViewRecipe,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Text(
                    'View Full Recipe ->',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.accentMuted,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PantryHint extends StatelessWidget {
  const _PantryHint({required this.gapCount, required this.missing});

  final int gapCount;
  final List<String> missing;

  @override
  Widget build(BuildContext context) {
    if (gapCount <= 0) {
      return Row(
        children: [
          const Icon(Icons.check_circle_outline,
              size: 15, color: AppColors.success),
          const SizedBox(width: 6),
          Text(
            'You have everything',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.success,
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    final label =
        missing.isEmpty ? '$gapCount to buy' : 'Missing: ${missing.join(', ')}';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.shopping_basket_outlined,
            size: 15, color: AppColors.accentMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.tertiaryMuted,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.matchPercentage});

  final int matchPercentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 13, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(
            '$matchPercentage% Match',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textDark,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardDots extends StatelessWidget {
  const _CardDots({required this.currentIndex, required this.totalRecipes});

  final int currentIndex;
  final int totalRecipes;

  @override
  Widget build(BuildContext context) {
    const maxDots = 8;
    final count = totalRecipes.clamp(0, maxDots);
    final active = currentIndex.clamp(0, count - 1 < 0 ? 0 : count - 1);

    return Row(
      children: List.generate(count, (index) {
        final selected = index == active;
        return Container(
          width: selected ? 7 : 5,
          height: selected ? 7 : 5,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.textMuted.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

String _titleCase(String enumValue) {
  return enumValue
      .split('_')
      .map((w) => w.isEmpty
          ? w
          : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');
}