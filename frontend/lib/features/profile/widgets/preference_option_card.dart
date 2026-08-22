import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

class PreferenceOptionCard extends StatelessWidget {
  const PreferenceOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.selected = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = selected ? AppColors.primary : AppColors.bgLight;
    final foregroundColor = selected ? AppColors.textDark : AppColors.textLight;
    final subtitleColor =
        selected ? AppColors.textDark.withValues(alpha: 0.82) : AppColors.textMuted;
    final borderColor = selected ? AppColors.primary : AppColors.divider;

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.label.copyWith(
                        color: foregroundColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.textDark,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}