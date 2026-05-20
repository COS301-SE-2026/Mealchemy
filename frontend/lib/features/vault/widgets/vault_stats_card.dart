import 'package:flutter/material.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

class VaultStatsCard extends StatelessWidget {
  const VaultStatsCard({
    super.key,
    required this.totalRecipes,
    required this.createdPercent,
    required this.categoryCount,
    required this.optimizationPercent,
  });

  final int totalRecipes;
  final int createdPercent;
  final int categoryCount;
  final int optimizationPercent;

  @override
  Widget build(BuildContext context) {
    final progress = (optimizationPercent.clamp(0, 100)) / 100;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _StatItem(
                value: '$totalRecipes',
                label: 'TOTAL RECIPES',
              ),
              const Spacer(),
              _StatItem(
                value: '$createdPercent%',
                label: 'CREATED',
                highlight: true,
              ),
              const Spacer(),
              // gradient divider line
              Container(
                width: 1,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.1),
                      AppColors.accent.withValues(alpha: 0.6),
                      AppColors.accent.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              const Spacer(),
              _StatItem(
                value: '$categoryCount',
                label: 'CATEGORIES',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gold accent line
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0),
                  AppColors.accent.withValues(alpha: 0.4),
                  AppColors.accent.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Meal optimization row
          Row(
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Meal Optimization',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '$optimizationPercent%',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar - crimson fill on warm background
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Highlighted value gets gold underline
        Stack(
          clipBehavior: Clip.none,
          children: [
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(
                color: highlight ? AppColors.primary : AppColors.textLight,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (highlight)
              Positioned(
                bottom: -4,
                left: 0,
                child: Container(
                  width: 24,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textMuted,
            fontSize: 10,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
