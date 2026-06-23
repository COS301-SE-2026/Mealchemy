import 'package:flutter/material.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';

class AppMatchBadge extends StatelessWidget {
  const AppMatchBadge({
    super.key,
    required this.percent,
    this.size = BadgeSize.medium,
  });

  final int percent;
  final BadgeSize size;

  double get _fontSize {
    switch (size) {
      case BadgeSize.small:
        return 9;
      case BadgeSize.medium:
        return 11;
      case BadgeSize.large:
        return 13;
    }
  }

  double get _iconSize {
    switch (size) {
      case BadgeSize.small:
        return 9;
      case BadgeSize.medium:
        return 11;
      case BadgeSize.large:
        return 14;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case BadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 3);
      case BadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case BadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: _iconSize,
            color: AppColors.textDark,
          ),
          const SizedBox(width: 4),
          Text(
            '$percent% Match',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textDark,
              fontSize: _fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

enum BadgeSize { small, medium, large }
