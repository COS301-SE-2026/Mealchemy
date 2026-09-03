import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

// Shown when the recommendation pool is exhausted. Summarizes the session from
// the real swipe counts. 
class DiscoveryCompleteState extends StatelessWidget {
  const DiscoveryCompleteState({
    super.key,
    required this.likedCount,
    required this.dislikedCount,
    required this.skippedCount,
    required this.onReset,
  });

  final int likedCount;
  final int dislikedCount;
  final int skippedCount;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.accent, size: 42),
          const SizedBox(height: 12),
          Text(
            "That's everything for now",
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.primary,
              fontSize: 30,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your swipes help tune what comes next. Check back soon for a fresh set.',
            style: AppTextStyles.body.copyWith(color: AppColors.tertiaryMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          _SessionSummary(
            likedCount: likedCount,
            dislikedCount: dislikedCount,
            skippedCount: skippedCount,
          ),
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
                style: AppTextStyles.button.copyWith(color: AppColors.textDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionSummary extends StatelessWidget {
  const _SessionSummary({
    required this.likedCount,
    required this.dislikedCount,
    required this.skippedCount,
  });

  final int likedCount;
  final int dislikedCount;
  final int skippedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryStat(
            icon: Icons.favorite,
            value: likedCount,
            label: 'LIKED',
          ),
          _SummaryStat(
            icon: Icons.close,
            value: dislikedCount,
            label: 'PASSED',
          ),
          _SummaryStat(
            icon: Icons.skip_next,
            value: skippedCount,
            label: 'SKIPPED',
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 20),
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primary,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 2),
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