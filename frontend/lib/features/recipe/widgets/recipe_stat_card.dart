import 'package:flutter/material.dart';

import '../../../core/shared_widgets/atoms/app_card.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

//icon, value, label stat tile
class RecipeStatCard extends StatelessWidget {
  const RecipeStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard.outlined(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accentMuted, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.title.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
