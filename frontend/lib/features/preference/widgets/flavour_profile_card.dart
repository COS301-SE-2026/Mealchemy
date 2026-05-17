import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

class FlavourProfileCard extends StatelessWidget {
  const FlavourProfileCard({
    super.key,
    required this.label,
    required this.imageUrl,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final String imageUrl;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceLight,
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1.55,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(imageUrl, fit: BoxFit.cover),
              if (selected)
                Container(color: AppColors.primary.withValues(alpha: 0.35)),
              Positioned(
                left: 18,
                bottom: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  color: AppColors.accent,
                  child: Text(
                    label.toUpperCase(),
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textLight,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
              if (selected)
                const Positioned(
                  right: 14,
                  bottom: 14,
                  child: CircleAvatar(
                    radius: 13,
                    backgroundColor: AppColors.textDark,
                    child: Icon(
                      Icons.check,
                      size: 17,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}