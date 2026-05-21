import 'package:flutter/material.dart';

import '../../../core/shared_widgets/atoms/app_card.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

//panel with an accent stripe down the left
class AlchemistTipCard extends StatelessWidget {
  const AlchemistTipCard({super.key, required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    return AppCard.accent(
      padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 3, color: AppColors.accent, height: 78),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: AppColors.accentMuted, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "ALCHEMIST'S TIP",
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.accentMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  tip,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                    height: 1.55,
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
