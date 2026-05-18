//main action buttons used across screens
import 'package:flutter/material.dart';
import 'package:mealchemy/core/theme/app_colours.dart';

//  Enums
enum ButtonVariant { primary, secondary, outlined, text }
// primary - solid background, white text
// secondary - solid accent background, white text
// outlined - transparent background, colored border and text
// text - transparent background, colored text
// Colour can be customized for the outlined and text button variants.

enum ButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final bool isRounded;
  final Color? customColor;
  final Color? customBorderColor;
  final IconData? leftIcon;
  final IconData? rightIcon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isRounded = false,
    this.customColor,
    this.customBorderColor,
    this.leftIcon,
    this.rightIcon,
  });

  // Convenience constructors
  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isRounded = false,
    this.leftIcon,
    this.rightIcon,
  }) : variant = ButtonVariant.primary,
        customColor = null,
        customBorderColor = null;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isRounded = false,
    this.leftIcon,
    this.rightIcon,
  }) : variant = ButtonVariant.secondary,
        customColor = null,
        customBorderColor = null;

  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isRounded = false,
    this.customColor,
    this.customBorderColor,
    this.leftIcon,
    this.rightIcon,
  }) : variant = ButtonVariant.outlined;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isRounded = false,
    this.customColor,
    this.leftIcon,
    this.rightIcon,
  }) : variant = ButtonVariant.text,
       customBorderColor = null;

  // Size getters
  double get _height {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  double get _fontSize {
    switch (size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
    }
  }

  double get _iconSize {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
    }
  }

  BorderRadius get _borderRadius =>
    isRounded ? BorderRadius.circular(100) : BorderRadius.circular(12);

  //  Child builder
  Widget _buildChild(Color textColor) {
    if (isLoading) {
      return SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: textColor,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leftIcon != null) ...[
          Icon(leftIcon, size: _iconSize, color: textColor),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        if (rightIcon != null) ...[
          const SizedBox(width: 8),
          Icon(rightIcon, size: _iconSize, color: textColor),
        ],
      ],
    );
  }

  //  Style builder
  ButtonStyle _buildStyle() {
    final shape = RoundedRectangleBorder(
      borderRadius: _borderRadius,
    );

    final padding = EdgeInsets.symmetric(
      horizontal: 20,
      vertical: size == ButtonSize.small ? 8 : 14,
    );

    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textDark,
          minimumSize: Size(isFullWidth ? double.infinity : 0, _height),
          textStyle:
              TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w600),
          padding: padding,
          shape: shape,
          elevation: 0,
        );

      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textLight,
          minimumSize: Size(isFullWidth ? double.infinity : 0, _height),
          textStyle:
              TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w600),
          padding: padding,
          shape: shape,
          elevation: 0,
        );

      case ButtonVariant.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: customColor ?? AppColors.primary,
          minimumSize: Size(isFullWidth ? double.infinity : 0, _height),
          textStyle:
              TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w600),
          padding: padding,
          shape: shape,
          side: BorderSide(color: customBorderColor ?? customColor ?? AppColors.primary, width: 1.5),
        );

      case ButtonVariant.text:
        return TextButton.styleFrom(
          foregroundColor: customColor ?? AppColors.primary,
          minimumSize: Size(isFullWidth ? double.infinity : 0, _height),
          textStyle:
              TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w600),
          padding: padding,
          shape: shape,
        );
    }
  }

  //  Build
  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          height: _height,
          child: ClipRRect(   
            borderRadius: _borderRadius,
            child: 
            DecoratedBox(
            decoration: BoxDecoration(
              gradient: onPressed != null ? AppColors.brand : null,
              color: onPressed == null
                  ? AppColors.textMuted.withValues(alpha: 0.3)
                  : null,

            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: _buildStyle().copyWith(
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                shadowColor: WidgetStateProperty.all(Colors.transparent),
              ),
              child: _buildChild(AppColors.textDark),
            ),
          ),
          )
        );

      case ButtonVariant.secondary:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          height: _height,
          child: ClipRRect(   
            borderRadius: _borderRadius,
            child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: _buildStyle(),
            child: _buildChild(AppColors.textLight),
          ),
        ),
        );

      case ButtonVariant.outlined:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          height: _height,
          child: ClipRRect(
            borderRadius: _borderRadius,
            child: OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: _buildStyle(),
              child: _buildChild(customColor ?? AppColors.primary),
            ),
          ),
        );
        
      case ButtonVariant.text:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          height: _height,
          child: ClipRRect(
            borderRadius: _borderRadius,
            child: TextButton(
              onPressed: isLoading ? null : onPressed,
              style: _buildStyle(),
              child: _buildChild(customColor ?? AppColors.primary),
            ),
          ),
        );
    }
  }
}
