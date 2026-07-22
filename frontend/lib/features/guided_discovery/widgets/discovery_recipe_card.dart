import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/discovery_recipe.dart';

//recipe recommendation card with recipe photo, perc, recipe details, nutritional info, cooking time
class DiscoveryRecipeCard extends StatelessWidget {
  const DiscoveryRecipeCard({
    super.key,
    required this.recipe,
    required this.currentIndex,
    required this.totalRecipes,
    this.onViewRecipe,
  });

  final DiscoveryRecipe recipe;
  final int currentIndex;
  final int totalRecipes;
  final VoidCallback? onViewRecipe;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        //restrict card size for uniformity across diff devices
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
                      Image.network(
                        recipe.imageUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.surfaceMuted,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.restaurant,
                              color: AppColors.textMuted,
                              size: 42,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        left: 14,
                        top: 14,
                        child: _MatchBadge(
                          matchPercentage: recipe.matchPercentage,
                        ),
                      ),
                    ],
                  ),
                ),
                _RecipeInfo(
                  recipe: recipe,
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

//shows recipe info and nutritional summary below recipe picture
class _RecipeInfo extends StatelessWidget {
  const _RecipeInfo({
    required this.recipe,
    required this.currentIndex,
    required this.totalRecipes,
    required this.onViewRecipe,
  });

  final DiscoveryRecipe recipe;
  final int currentIndex;
  final int totalRecipes;
  final VoidCallback? onViewRecipe;

  @override
  Widget build(BuildContext context) {
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
          Text.rich(
            TextSpan(
              text: 'by ',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.tertiaryMuted,
                fontSize: 12,
              ),
              children: [
                TextSpan(
                  text: recipe.chefName,
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NutritionStat(
                icon: Icons.local_fire_department_outlined,
                value: recipe.calories.toString(),
                label: 'KCAL',
              ),
              _NutritionStat(
                icon: Icons.egg_alt_outlined,
                value: '${recipe.proteinGrams}g',
                label: 'PROT',
              ),
              _NutritionStat(
                icon: Icons.bakery_dining_outlined,
                value: '${recipe.carbsGrams}g',
                label: 'CARBS',
              ),
              _NutritionStat(
                icon: Icons.water_drop_outlined,
                value: '${recipe.fatGrams}g',
                label: 'FAT',
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 9),
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 15,
                color: AppColors.primary,
              ),
              const SizedBox(width: 5),
              Text(
                '${recipe.cookTimeMinutes}m',
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

//displays percentage match
class _MatchBadge extends StatelessWidget {
  const _MatchBadge({
    required this.matchPercentage,
  });

  final int matchPercentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 13,
            color: AppColors.accent,
          ),
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

//nutritional information (calories, carbs, fats, etc)
class _NutritionStat extends StatelessWidget {
  const _NutritionStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 16),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTextStyles.label.copyWith(
            color: AppColors.primary,
            fontSize: 11,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.tertiaryMuted,
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}

//carousel for recipe cards
class _CardDots extends StatelessWidget {
  const _CardDots({
    required this.currentIndex,
    required this.totalRecipes,
  });

  final int currentIndex;
  final int totalRecipes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalRecipes, (index) {
        final selected = index == currentIndex;

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