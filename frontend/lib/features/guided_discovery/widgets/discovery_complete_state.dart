import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/discovery_recipe.dart';

//displays completion screen shown after user has reviewed all reommended recipes
class DiscoveryCompleteState extends StatelessWidget {
  const DiscoveryCompleteState({
    super.key,
    //recipe counts
    required this.likedCount,
    required this.dislikedCount,
    required this.tasteSignals,
    required this.recommendedRecipe,
    required this.onReset,
  });

  final int likedCount;
  final int dislikedCount;
  final List<String> tasteSignals;
  final DiscoveryRecipe? recommendedRecipe;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final signals = tasteSignals.isEmpty
        ? ['Balanced', 'Flexible', 'Exploratory']
        : tasteSignals;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
      child: Column(
        children: [
          const Icon(
            Icons.auto_awesome,
            color: AppColors.accent,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            'Taste profile ready',
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.primary,
              fontSize: 30,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          //summary
          Text(
            'Your mock recommendations were shaped by $likedCount likes and $dislikedCount skips.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.tertiaryMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          _TasteSignalSection(signals: signals),
          if (recommendedRecipe != null) ...[
            const SizedBox(height: 18),
            _RecommendedRecipeCard(recipe: recommendedRecipe!),
          ],
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onReset,
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
                'Start Again',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TasteSignalSection extends StatelessWidget {
  const _TasteSignalSection({
    required this.signals,
  });

  final List<String> signals;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Taste signals',
            style: AppTextStyles.label.copyWith(
              color: AppColors.primary,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: signals.map((signal) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Text(
                  signal,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                    fontSize: 11,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RecommendedRecipeCard extends StatelessWidget {
  const _RecommendedRecipeCard({
    required this.recipe,
  });

  final DiscoveryRecipe recipe;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentMuted.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            height: 124,
            child: Image.network(
              recipe.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended next',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.accentMuted,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${recipe.matchPercentage}% match • ${recipe.cookTimeMinutes}m',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.tertiaryMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}