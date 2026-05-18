import 'package:flutter/material.dart';
import 'package:mealchemy/core/theme/app_colours.dart';

enum CardVariant { gradient, light, dark, accent, outlined }

class AppCard extends StatelessWidget {
  final Widget child;
  final CardVariant variant;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final double borderRadius;
  final Gradient? gradient;

  const AppCard({
    super.key,
    required this.child,
    this.variant = CardVariant.light,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.borderRadius = 16,
    this.gradient,
  });

  const AppCard.light({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.borderRadius = 16,
    this.gradient,
  }) : variant = CardVariant.light;

  const AppCard.dark({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.borderRadius = 16,
    this.gradient,
  }) : variant = CardVariant.dark;

  const AppCard.accent({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.borderRadius = 16,
    this.gradient,
  }) : variant = CardVariant.accent;

  const AppCard.outlined({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.borderRadius = 16,
    this.gradient,
  }) : variant = CardVariant.outlined;

  const AppCard.gradient({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.borderRadius = 16,
    this.gradient,
  }) : variant = CardVariant.gradient;

  //Variant config
  Color get _backgroundColor {
    switch (variant) {
      case CardVariant.light:
        return AppColors.surfaceWhite;
      case CardVariant.dark:
        return AppColors.primary;
      case CardVariant.accent:
        return AppColors.accentLight;
      case CardVariant.outlined:
        return Colors.transparent;
      case CardVariant.gradient:
        return Colors.transparent;
    }
  }

  Border? get _border {
    switch (variant) {
      case CardVariant.outlined:
        return Border.all(color: AppColors.accent, width: 1.5);
      default:
        return null;
    }
  }

  BoxShadow? get _shadow {
    switch (variant) {
      case CardVariant.light:
      case CardVariant.accent:
        return BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        );
      default:
        return null;
    }
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (variant == CardVariant.gradient || gradient != null)
              ? null
              : _backgroundColor,
          gradient: variant == CardVariant.gradient
              ? (gradient ?? AppColors.brand) 
              : gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          border: _border,
          boxShadow: _shadow != null ? [_shadow!] : null,
        ),
        child: child,
      ),
    );
  }
}
