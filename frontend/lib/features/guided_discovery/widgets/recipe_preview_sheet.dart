import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/recommendation.dart';
import '../models/signal_scores.dart';

// Quick look sheet for a recommended card
class RecipePreviewSheet extends StatelessWidget {
  const RecipePreviewSheet({
    super.key,
    required this.recommendation,
    this.onViewFullRecipe,
  });

  final Recommendation recommendation;
  final VoidCallback? onViewFullRecipe;

  @override
  Widget build(BuildContext context) {
    final recipe = recommendation.recipe;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 18),
            _PreviewImage(
              url: recipe.photoUrl,
              matchPercent: recommendation.matchPercent,
            ),
            const SizedBox(height: 18),
            Text(
              recipe.title,
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.primary,
                fontSize: 30,
              ),
            ),
            if (recipe.cuisineType != null) ...[
              const SizedBox(height: 6),
              Text(
                _titleCase(recipe.cuisineType!),
                style: AppTextStyles.bodyBold.copyWith(
                  color: AppColors.tertiaryMuted,
                ),
              ),
            ],
            if (recipe.description != null &&
                recipe.description!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                recipe.description!,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.tertiaryMuted,
                ),
              ),
            ],
            const SizedBox(height: 20),
            _PreviewStats(recommendation: recommendation),
            const SizedBox(height: 18),
            _MatchReasonCard(signals: recommendation.scoreBreakdown),
            if (recommendation.pantryGapCount > 0) ...[
              const SizedBox(height: 18),
              _MissingIngredients(
                gapCount: recommendation.pantryGapCount,
                missing: recommendation.missingIngredients,
              ),
            ],
            const SizedBox(height: 22),
            _PreviewActions(
              onClose: () => Navigator.of(context).pop(),
              onViewFullRecipe: onViewFullRecipe == null
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      onViewFullRecipe!();
                    },
            ),
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
  const _PreviewImage({required this.url, required this.matchPercent});

  final String? url;
  final int matchPercent;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: const Icon(Icons.restaurant, color: AppColors.textMuted, size: 42),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: AspectRatio(
        aspectRatio: 1.45,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url == null || url!.isEmpty)
              placeholder
            else
              Image.network(
                url!,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) => placeholder,
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
                      '$matchPercent% Match',
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

class _PreviewStats extends StatelessWidget {
  const _PreviewStats({required this.recommendation});

  final Recommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final recipe = recommendation.recipe;
    final total = (recipe.prepTimeMins ?? 0) + (recipe.cookingTimeMins ?? 0);

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
          _PreviewStat(value: '${recipe.prepTimeMins ?? 0}m', label: 'PREP'),
          _PreviewStat(value: '${recipe.cookingTimeMins ?? 0}m', label: 'COOK'),
          _PreviewStat(value: '${total}m', label: 'TOTAL'),
          _PreviewStat(
            value: '${recipe.servingSize ?? 0}',
            label: 'SERVES',
          ),
        ],
      ),
    );
  }
}

class _PreviewStat extends StatelessWidget {
  const _PreviewStat({required this.value, required this.label});

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

// Turned the top score signals into a short human readable explanation of why this recipe was recommended
class _MatchReasonCard extends StatelessWidget {
  const _MatchReasonCard({required this.signals});

  final SignalScores signals;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
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
                  _reason(signals),
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

  String _reason(SignalScores s) {
    final ranked = <MapEntry<String, double>>[
      MapEntry('it uses what you already have', s.pantryMatch),
      MapEntry('it fits your favourite cuisines', s.cuisine),
      MapEntry('it lines up with your nutrition goals', s.nutrition),
      MapEntry('the ingredients are in season', s.freshness),
      MapEntry("it's something new to try", s.novelty),
    ]..sort((a, b) => b.value.compareTo(a.value));

    final top = ranked.take(2).map((e) => e.key).toList();
    if (top.isEmpty) return 'A solid all-round match for your profile.';
    if (top.length == 1) return 'Recommended because ${top.first}.';
    return 'Recommended because ${top.first}, and ${top.last}.';
  }
}

class _MissingIngredients extends StatelessWidget {
  const _MissingIngredients({required this.gapCount, required this.missing});

  final int gapCount;
  final List<String> missing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            gapCount == 1 ? "You're missing 1 item" : "You're missing $gapCount items",
            style: AppTextStyles.title.copyWith(color: AppColors.primary),
          ),
          if (missing.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...missing.map((name) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_basket_outlined,
                          color: AppColors.accentMuted, size: 17),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _PreviewActions extends StatelessWidget {
  const _PreviewActions({required this.onClose, this.onViewFullRecipe});

  final VoidCallback onClose;
  final VoidCallback? onViewFullRecipe;

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
            onPressed: onViewFullRecipe ?? onClose,
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
              onViewFullRecipe == null ? 'Looks Good' : 'View Full Recipe',
              style: AppTextStyles.button.copyWith(color: AppColors.textDark),
            ),
          ),
        ),
      ],
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