import 'package:flutter/material.dart';
import 'package:mealchemy/core/theme/app_colours.dart';

enum IconButtonVariant { primary, secondary, outlined, outlinedSecondary,primaryGhost,secondaryGhost}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final IconButtonVariant variant;
  final double size;
  final bool isLoading;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = IconButtonVariant.primary,
    this.size = 48,
    this.isLoading = false,
  });

  const AppIconButton.primary({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 48,
    this.isLoading = false,
  }) : variant = IconButtonVariant.primary;

  const AppIconButton.secondary({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 48,
    this.isLoading = false,
  }) : variant = IconButtonVariant.secondary;

  const AppIconButton.outlined({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 48,
    this.isLoading = false,
  }) : variant = IconButtonVariant.outlined;

  const AppIconButton.outlinedSecondary({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 48,
    this.isLoading = false,
  }) : variant = IconButtonVariant.outlinedSecondary;

  const AppIconButton.primaryGhost({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 48,
    this.isLoading = false,
  }) : variant = IconButtonVariant.primaryGhost;

  const AppIconButton.secondaryGhost({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 48,
    this.isLoading = false,
  }) : variant = IconButtonVariant.secondaryGhost;

  // Variant config
  Color get _backgroundColor {
    switch (variant) {
      case IconButtonVariant.primary:          return AppColors.primary;
      case IconButtonVariant.secondary:        return AppColors.accent;
      case IconButtonVariant.outlined:         return Colors.transparent;
      case IconButtonVariant.outlinedSecondary: return Colors.transparent;
      case IconButtonVariant.primaryGhost:     return Colors.transparent;
      case IconButtonVariant.secondaryGhost:   return Colors.transparent;
    }
  }

  Color get _iconColor {
    switch (variant) {
      case IconButtonVariant.primary:          return AppColors.textDark;
      case IconButtonVariant.secondary:        return AppColors.textDark;
      case IconButtonVariant.outlined:         return AppColors.primary;
      case IconButtonVariant.outlinedSecondary: return AppColors.accent;
      case IconButtonVariant.primaryGhost:     return AppColors.primary;
      case IconButtonVariant.secondaryGhost:   return AppColors.accent;
    }
  }

  Border? get _border {
    switch (variant) {
      case IconButtonVariant.outlined:
        return Border.all(color: AppColors.primary, width: 1.5);
      case IconButtonVariant.outlinedSecondary:
        return Border.all(color: AppColors.accent, width: 1.5);
      default:
        return null;
    }
  }

  Gradient? get _gradient {
    if (variant == IconButtonVariant.primary && onPressed != null) {
      return AppColors.brand;
    }
    return null;
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _gradient,
          color: _gradient == null ? _backgroundColor : null,
          border: _border,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: size * 0.4,
                  height: size * 0.4,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _iconColor,
                  ),
                )
              : Icon(
                  icon,
                  color: onPressed == null
                      ? AppColors.textMuted
                      : _iconColor,
                  size: size * 0.45,
                ),
        ),
      ),
    );
  }
}