import 'package:flutter/material.dart';
import 'package:mealchemy/core/theme/app_colours.dart';

enum IconButtonVariant { primary, secondary, outlined, ghost, gradientIcon }
//primary - solid background, white text
//secondary - solid accent background, white text
//outlined - transparent background, colored border and text ( can customize border and text colour )
//ghost - transparent background, transparent border, colored text (can customize text colour)
//gradientIcon - Primary colour gradient rounded-square tile with a white

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final IconButtonVariant variant;
  final Color? customColor;
  final Color? customBorderColor;
  final double size;
  final bool isLoading;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = IconButtonVariant.primary,
    this.customColor,
    this.customBorderColor,
    this.size = 48,
    this.isLoading = false,
  });

  const AppIconButton.primary({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 48,
    this.isLoading = false,
  })  : variant = IconButtonVariant.primary,
        customColor = null,
        customBorderColor = null;

  const AppIconButton.secondary({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 48,
    this.isLoading = false,
  })  : variant = IconButtonVariant.secondary,
        customColor = null,
        customBorderColor = null;

  const AppIconButton.outlined({
    super.key,
    required this.icon,
    required this.onPressed,
    this.customColor,
    this.customBorderColor,
    this.size = 48,
    this.isLoading = false,
  }) : variant = IconButtonVariant.outlined;

  const AppIconButton.ghost({
    super.key,
    required this.icon,
    required this.onPressed,
    this.customColor,
    this.size = 48,
    this.isLoading = false,
  })  : variant = IconButtonVariant.ghost,
        customBorderColor = null;

  const AppIconButton.gradientIcon({
    super.key,
    required this.icon,
    this.onPressed,
    this.customColor,
    this.size = 46,
    this.isLoading = false,
  })  : variant = IconButtonVariant.gradientIcon,
        customBorderColor = null;

  //Variant config
  Color get _backgroundColor {
    switch (variant) {
      case IconButtonVariant.primary:
        return AppColors.primary;
      case IconButtonVariant.secondary:
        return AppColors.accent;
      case IconButtonVariant.outlined:
        return Colors.transparent;
      case IconButtonVariant.ghost:
        return Colors.transparent;
      case IconButtonVariant.gradientIcon:
        return AppColors.primary;
    }
  }

  Color get _iconColor {
    switch (variant) {
      case IconButtonVariant.primary:
        return AppColors.textDark;
      case IconButtonVariant.secondary:
        return AppColors.textDark;
      case IconButtonVariant.outlined:
        return customColor ?? AppColors.primary;
      case IconButtonVariant.ghost:
        return customColor ?? AppColors.primary;
      case IconButtonVariant.gradientIcon:
        return customColor ?? AppColors.surfaceWhite;
    }
  }

  Border? get _border {
    switch (variant) {
      case IconButtonVariant.outlined:
        return Border.all(
          color: customBorderColor ?? customColor ?? AppColors.primary,
          width: 1.5,
        );
      default:
        return null;
    }
  }

  Gradient? get _gradient {
    if (variant == IconButtonVariant.primary && onPressed != null) {
      return AppColors.brand;
    }
    if (variant == IconButtonVariant.gradientIcon) {
      return AppColors.brand;
    }
    return null;
  }

  // Build
  @override
  Widget build(BuildContext context) {
    if (variant == IconButtonVariant.gradientIcon) {
      return _buildTile();
    }

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
                  color: onPressed == null ? AppColors.textMuted : _iconColor,
                  size: size * 0.45,
                ),
        ),
      ),
    );
  }

  Widget _buildTile() {
    final tile = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: _gradient,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: _iconColor, size: size * 0.48),
    );

    if (onPressed == null) return tile;
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: tile,
    );
  }
}