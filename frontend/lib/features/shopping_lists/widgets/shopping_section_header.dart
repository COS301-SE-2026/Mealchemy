import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

//small uppercase section heading used between shopping list groups
class ShoppingSectionHeader extends StatelessWidget {
  const ShoppingSectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.label.copyWith(
            color: AppColors.primary,
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.accent.withValues(alpha: 0.75),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          Text(
            trailing!.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.tertiaryMuted,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}