import 'package:flutter/material.dart';

import '../../theme/app_colours.dart';
import '../../theme/app_typography.dart';

enum SectionHeaderSize { small, medium, large }

enum SectionHeaderWeight { normal, semiBold, bold }

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onTrailingTap,
    this.showAccentLine = true,
    this.size = SectionHeaderSize.medium,
    this.weight = SectionHeaderWeight.semiBold,
  });

  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;
  final bool showAccentLine;
  final SectionHeaderSize size;
  final SectionHeaderWeight weight;

  double get _fontSize {
    switch (size) {
      case SectionHeaderSize.small:
        return 13;
      case SectionHeaderSize.medium:
        return 16;
      case SectionHeaderSize.large:
        return 20;
    }
  }

  FontWeight get _fontWeight {
    switch (weight) {
      case SectionHeaderWeight.normal:
        return FontWeight.w400;
      case SectionHeaderWeight.semiBold:
        return FontWeight.w600;
      case SectionHeaderWeight.bold:
        return FontWeight.w800;
    }
  }

  // bar thickness scaled to the text size
  double get _barThickness {
    switch (size) {
      case SectionHeaderSize.small:
        return 1.5;
      case SectionHeaderSize.medium:
        return 2;
      case SectionHeaderSize.large:
        return 2.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //Title
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontSize: _fontSize,
            fontWeight: _fontWeight,
            color: AppColors.primaryLight,
          ),
        ),
        //Horizontal accent line
        if (showAccentLine) ...[
          const SizedBox(width: 10),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ],
        if (trailing != null) ...[
          const Spacer(),
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(
              trailing!,
              style: AppTextStyles.label.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 0.5,
                fontSize: _fontSize - 4,
              ),
            ),
          )
        ],
      ],
    );
  }
}
