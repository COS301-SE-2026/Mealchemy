import 'package:flutter/material.dart';

import '../../theme/app_colours.dart';
import '../../theme/app_typography.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.showAccentLine = true,
  });

  final String title;
  final String? trailing;
  final bool showAccentLine;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showAccentLine) ...[
          Container(width: 2, height: 18, color: AppColors.primary),
          const SizedBox(width: 12),
        ],
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          Text(
            trailing!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}