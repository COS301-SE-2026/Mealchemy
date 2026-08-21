import 'package:flutter/material.dart';

import '../../theme/app_colours.dart';
import '../../theme/app_typography.dart';
import '../atoms/app_icon_button.dart';

enum SectionHeaderSize { small, medium, large }

enum SectionHeaderWeight { normal, semiBold, bold }
// Two variants of section headers: 
// Line variadnt: a line accent to the right of the title
// Icon variant: a gradient icon tile to the left of the title with optonal subtitle
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onTrailingTap,
    this.showAccentLine = true,
    this.size = SectionHeaderSize.medium,
    this.weight = SectionHeaderWeight.semiBold,
    this.titleStyle,
  })  : icon = null,
        subtitle = null,
        _variant = _HeaderVariant.line;
  const AppSectionHeader.icon({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
  })  : trailing = null,
        onTrailingTap = null,
        showAccentLine = false,
        size = SectionHeaderSize.large,
        weight = SectionHeaderWeight.bold,
        titleStyle = null,
        _variant = _HeaderVariant.icon;

  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;
  final bool showAccentLine;
  final SectionHeaderSize size;
  final SectionHeaderWeight weight;
  final TextStyle? titleStyle;
  final IconData? icon;
  final String? subtitle;
  final _HeaderVariant _variant;

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

  @override
  Widget build(BuildContext context) {
    if (_variant == _HeaderVariant.icon) return _buildIcon();
    return _buildLine();
  }

  Widget _buildIcon() {
    return Row(
      children: [
        AppIconButton.gradientIcon(icon: icon!),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null) ...[
                Text(
                  subtitle!.toUpperCase(),
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.accentMuted,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 3),
              ],
              Text(
                title,
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLine() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: titleStyle ??
              AppTextStyles.body.copyWith(
                fontSize: _fontSize,
                fontWeight: _fontWeight,
                color: AppColors.primaryLight,
              ),
        ),
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
          ),
        ],
      ],
    );
  }
}

enum _HeaderVariant { line, icon }