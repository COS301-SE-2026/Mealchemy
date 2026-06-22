import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/discovery_recipe.dart';

//preview of recipe
class RecipePreviewSheet extends StatelessWidget {
  const RecipePreviewSheet({
    super.key,
    required this.recipe,
  });

  //recipe data
  final DiscoveryRecipe recipe;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 18),
            _PreviewImage(recipe: recipe),
            const SizedBox(height: 18),
            Text(
              recipe.title,
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.primary,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                text: 'by ',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.tertiaryMuted,
                ),
                children: [
                  TextSpan(
                    text: recipe.chefName,
                    style: AppTextStyles.bodyBold.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              recipe.description,
              style: AppTextStyles.body.copyWith(
                color: AppColors.tertiaryMuted,
              ),
            ),
            const SizedBox(height: 16),
            //recipe category, nutritional tags
            _TagWrap(tags: recipe.tags),
            const SizedBox(height: 20),
            //recipe stats
            _PreviewStats(recipe: recipe),
            const SizedBox(height: 18),
            _MatchReasonCard(recipe: recipe),
            const SizedBox(height: 22),
            _IngredientSection(ingredients: recipe.ingredients),
            const SizedBox(height: 22),
            _StepSection(steps: recipe.steps),
            const SizedBox(height: 22),
            _PreviewActions(onClose: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({
    required this.recipe,
  });

  final DiscoveryRecipe recipe;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: AspectRatio(
        aspectRatio: 1.45,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              recipe.imageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            Positioned(
              left: 14,
              top: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgDark.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.accent,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${recipe.matchPercentage}% Match',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textDark,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagWrap extends StatelessWidget {
  const _TagWrap({
    required this.tags,
  });

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.16),
            ),
          ),
          child: Text(
            tag,
            style: AppTextStyles.label.copyWith(
              color: AppColors.primary,
              fontSize: 10,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PreviewStats extends StatelessWidget {
  const _PreviewStats({
    required this.recipe,
  });

  final DiscoveryRecipe recipe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _PreviewStat(
            value: '${recipe.cookTimeMinutes}m',
            label: 'TIME',
          ),
          _PreviewStat(
            value: recipe.calories.toString(),
            label: 'KCAL',
          ),
          _PreviewStat(
            value: '${recipe.proteinGrams}g',
            label: 'PROT',
          ),
          _PreviewStat(
            value: '${recipe.fatGrams}g',
            label: 'FAT',
          ),
        ],
      ),
    );
  }
}

class _PreviewStat extends StatelessWidget {
  const _PreviewStat({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyBold.copyWith(
            color: AppColors.primary,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.tertiaryMuted,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

class _MatchReasonCard extends StatelessWidget {
  const _MatchReasonCard({
    required this.recipe,
  });

  final DiscoveryRecipe recipe;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome,
            color: AppColors.accent,
            size: 20,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why this matches you',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  recipe.matchReason,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.tertiaryMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientSection extends StatelessWidget {
  const _IngredientSection({
    required this.ingredients,
  });

  final List<String> ingredients;

  @override
  Widget build(BuildContext context) {
    return _PreviewSection(
      title: 'Ingredients',
      children: ingredients.map((ingredient) {
        return _CheckRow(label: ingredient);
      }).toList(),
    );
  }
}

class _StepSection extends StatelessWidget {
  const _StepSection({
    required this.steps,
  });

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return _PreviewSection(
      title: 'Mock method',
      children: List.generate(steps.length, (index) {
        return _NumberedRow(
          number: index + 1,
          label: steps[index],
        );
      }),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.title.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.accent,
            size: 17,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberedRow extends StatelessWidget {
  const _NumberedRow({
    required this.number,
    required this.label,
  });

  final int number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 23,
            height: 23,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number.toString(),
              style: AppTextStyles.label.copyWith(
                color: AppColors.textDark,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewActions extends StatelessWidget {
  const _PreviewActions({
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onClose,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Close Preview',
              style: AppTextStyles.button.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textDark,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Looks Good',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
}