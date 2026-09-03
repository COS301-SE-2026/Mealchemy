import 'package:flutter/material.dart';

import '../../theme/app_colours.dart';
import '../../theme/app_typography.dart';

// Small count bubble meant to sit over an icon in a Stack,  Renders nothing
// when count is equal = 0, so callers can drop it in unconditionally.
class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      constraints: const BoxConstraints(minWidth: 18),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.bgLight, width: 1.5),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: AppTextStyles.label.copyWith(
          color: AppColors.textLight,
          fontSize: 9,
          letterSpacing: 0,
        ),
      ),
    );
  }
}