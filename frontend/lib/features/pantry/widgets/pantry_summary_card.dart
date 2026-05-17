import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

class PantrySummaryCard extends StatelessWidget {
  const PantrySummaryCard({
    super.key,
    required this.totalItems,
    required this.freshnessPercent,
    required this.categoryCount,
    required this.optimizationPercent,
  });

  final int totalItems;
  final int freshnessPercent;
  final int categoryCount;
  final int optimizationPercent;

  @override
  Widget build(BuildContext context) {
    final progress = (optimizationPercent.clamp(0, 100)) / 100;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent),
        boxShadow: [
          BoxShadow(
            color: AppColors.textLight.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _SummaryMetric(
                value: '$totalItems',
                label: 'TOTAL ITEMS',
              ),
              const Spacer(),
              _SummaryMetric(
                value: '$freshnessPercent%',
                label: 'FRESHNESS',
                highlight: true,
              ),
              const Spacer(),
              Container(width: 1, height: 52, color: AppColors.primary),
              const Spacer(),
              _SummaryMetric(
                value: '$categoryCount',
                label: 'CATEGORIES',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Meal Optimization',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '$optimizationPercent%',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceLight,
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

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
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
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(
            color: highlight ? AppColors.primary : AppColors.textLight,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textMuted,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}