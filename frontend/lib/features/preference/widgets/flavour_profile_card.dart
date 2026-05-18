import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

class FlavourProfileCard extends StatelessWidget {
  const FlavourProfileCard({
    super.key,
    required this.label,
    required this.description,
    required this.icon,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        selected ? AppColors.primary : AppColors.surfaceLight;
    final foregroundColor =
        selected ? AppColors.textDark : AppColors.textLight;
    final mutedColor = selected
        ? AppColors.textDark.withValues(alpha: 0.78)
        : AppColors.textMuted;

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.divider,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.textDark.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: selected ? AppColors.textDark : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: AppTextStyles.label.copyWith(
                        color: foregroundColor,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: mutedColor,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                selected ? Icons.check_circle : Icons.add_circle_outline,
                color: selected ? AppColors.textDark : AppColors.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}