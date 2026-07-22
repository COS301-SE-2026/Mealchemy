//main action buttons used across screens
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';

//  Enums
enum ButtonVariant { primary, secondary, outlined, text }
// primary - solid background, white text
// secondary - solid accent background, white text
// outlined - transparent background, colored border and text
// text - transparent background, colored text
// Colour can be customized for the outlined and text button variants.

enum ButtonSize { small, medium, large }

//new states for buttons
enum AppButtonStatus { idle, loading, success, error }

class AppButton extends StatefulWidget {
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

  final AppButtonStatus status;
  final String? errorMessage;
  final VoidCallback? onSuccessComplete;

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
    this.status = AppButtonStatus.idle,
    this.errorMessage,
    this.onSuccessComplete,
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
    this.status = AppButtonStatus.idle,
    this.errorMessage,
    this.onSuccessComplete,
  })  : variant = ButtonVariant.primary,
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
    this.status = AppButtonStatus.idle,
    this.errorMessage,
    this.onSuccessComplete,
  })  : variant = ButtonVariant.secondary,
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
    this.status = AppButtonStatus.idle,
    this.errorMessage,
    this.onSuccessComplete,
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
    this.status = AppButtonStatus.idle,
    this.errorMessage,
    this.onSuccessComplete,
  })  : variant = ButtonVariant.text,
        customBorderColor = null;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  static const _shakeDuration = Duration(milliseconds: 420);
  static const _swapDuration = Duration(milliseconds: 180);
  static const _fillDuration = Duration(milliseconds: 200);
  static const _successHold = Duration(milliseconds: 900);
  static const _errorRevert = Duration(milliseconds: 2500);

  late final AnimationController _shakeController;

  late AppButtonStatus _displayStatus;
  Timer? _revertTimer;
  Timer? _successTimer;
  double? _lockedWidth;
  bool _isPressed = false;
  AppButtonStatus get _effectiveStatus =>
      widget.isLoading ? AppButtonStatus.loading : widget.status;

  @override
  void initState() {
    super.initState();
    _displayStatus = _effectiveStatus;
    _shakeController =
        AnimationController(vsync: this, duration: _shakeDuration);
    if (_displayStatus == AppButtonStatus.error) _enterError(shake: false);
    if (_displayStatus == AppButtonStatus.success) _enterSuccess();
  }

  @override
  void didUpdateWidget(covariant AppButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldStatus =
        oldWidget.isLoading ? AppButtonStatus.loading : oldWidget.status;
    final newStatus = _effectiveStatus;
    if (oldStatus == newStatus) return;

    if (oldStatus == AppButtonStatus.idle && !widget.isFullWidth) {
      _lockedWidth = context.size?.width;
    }

    _revertTimer?.cancel();
    _successTimer?.cancel();
    setState(() => _displayStatus = newStatus);

    switch (newStatus) {
      case AppButtonStatus.error:
        _enterError(shake: true);
      case AppButtonStatus.success:
        _enterSuccess();
      case AppButtonStatus.idle:
        _lockedWidth = null;
      case AppButtonStatus.loading:
        break;
    }
  }

  void _enterError({required bool shake}) {
    if (shake) {
      HapticFeedback.mediumImpact();
      _shakeController.forward(from: 0);
    }
    _revertTimer = Timer(_errorRevert, () {
      if (!mounted) return;
      setState(() {
        _displayStatus = AppButtonStatus.idle;
        _lockedWidth = null;
      });
    });
  }

  void _enterSuccess() {
    HapticFeedback.lightImpact();
    _successTimer = Timer(_successHold, () {
      if (!mounted) return;
      widget.onSuccessComplete?.call();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _revertTimer?.cancel();
    _successTimer?.cancel();
    super.dispose();
  }

  // Size getters
  double get _height {
    switch (widget.size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
    }
  }

  BorderRadius get _borderRadius =>
      widget.isRounded ? BorderRadius.circular(100) : BorderRadius.circular(12);

  bool get _isFilled =>
      widget.variant == ButtonVariant.primary ||
      widget.variant == ButtonVariant.secondary;

  Color get _accentColor => widget.customColor ?? AppColors.primary;

  static final Color _loadingFill = AppColors.primary.withValues(alpha: 0.08);

  //  Status driven colours
  Color _foregroundColor() {
    switch (_displayStatus) {
      case AppButtonStatus.loading:
        return _isFilled ? AppColors.primary : _accentColor;
      case AppButtonStatus.success:
        return _isFilled ? AppColors.textDark : AppColors.success;
      case AppButtonStatus.error:
        return _isFilled ? AppColors.textDark : AppColors.error;
      case AppButtonStatus.idle:
        switch (widget.variant) {
          case ButtonVariant.primary:
            return AppColors.textDark;
          case ButtonVariant.secondary:
            return AppColors.textLight;
          case ButtonVariant.outlined:
          case ButtonVariant.text:
            return _accentColor;
        }
    }
  }

  BoxDecoration _fillDecoration() {
    if (!_isFilled) {
      //outlined and text variants
      final borderColor = switch (_displayStatus) {
        AppButtonStatus.error => AppColors.error,
        AppButtonStatus.success => AppColors.success,
        _ => widget.customBorderColor ?? _accentColor,
      };
      return BoxDecoration(
        borderRadius: _borderRadius,
        border: widget.variant == ButtonVariant.outlined
            ? Border.all(color: borderColor, width: 1.5)
            : null,
      );
    }

    switch (_displayStatus) {
      case AppButtonStatus.loading:
        return BoxDecoration(borderRadius: _borderRadius, color: _loadingFill);
      case AppButtonStatus.success:
        return BoxDecoration(
            borderRadius: _borderRadius, color: AppColors.success);
      case AppButtonStatus.error:
        return BoxDecoration(
            borderRadius: _borderRadius, color: AppColors.error);
      case AppButtonStatus.idle:
        if (widget.onPressed == null) {
          return BoxDecoration(
            borderRadius: _borderRadius,
            color: AppColors.textMuted.withValues(alpha: 0.3),
          );
        }
        return widget.variant == ButtonVariant.primary
            ? BoxDecoration(
                borderRadius: _borderRadius, gradient: AppColors.brand)
            : BoxDecoration(
                borderRadius: _borderRadius, color: AppColors.accent);
    }
  }

  //  Child builder
  Widget _buildChild(Color foreground) {
    switch (_displayStatus) {
      case AppButtonStatus.loading:
        return SizedBox(
          key: const ValueKey('loading'),
          width: _iconSize,
          height: _iconSize,
          child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
        );

      case AppButtonStatus.success:
        return Icon(
          Icons.check_rounded,
          key: const ValueKey('success'),
          size: _iconSize + 4,
          color: foreground,
        );

      case AppButtonStatus.error:
      case AppButtonStatus.idle:
        return Row(
          key: ValueKey(_displayStatus),
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.leftIcon != null) ...[
              Icon(widget.leftIcon, size: _iconSize, color: foreground),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: AppTextStyles.button.copyWith(
                fontSize: _fontSize,
                color: foreground,
              ),
            ),
            if (widget.rightIcon != null) ...[
              const SizedBox(width: 8),
              Icon(widget.rightIcon, size: _iconSize, color: foreground),
            ],
          ],
        );
    }
  }

  //  Build
  @override
  Widget build(BuildContext context) {
    final foreground = _foregroundColor();

    //tap disabled while working
    final effectiveOnPressed = switch (_displayStatus) {
      AppButtonStatus.loading || AppButtonStatus.success => null,
      _ => widget.onPressed,
    };

    Widget button = SizedBox(
      width: widget.isFullWidth ? double.infinity : _lockedWidth,
      height: _height,
      child: AnimatedContainer(
        duration: _fillDuration,
        curve: Curves.easeOut,
        decoration: _fillDecoration(),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: effectiveOnPressed,
            borderRadius: _borderRadius,
            //hover and pressed feedback depends on the foreground colour
            //dark ink on light fills, light ink on the gradient and status fills
            overlayColor: WidgetStateProperty.resolveWith((states) {
              final ink = _isFilled && _displayStatus != AppButtonStatus.loading
                  ? AppColors.textDark
                  : _accentColor;
              if (states.contains(WidgetState.pressed)) {
                return ink.withValues(alpha: 0.16);
              }
              if (states.contains(WidgetState.hovered)) {
                return ink.withValues(alpha: 0.08);
              }
              if (states.contains(WidgetState.focused)) {
                return ink.withValues(alpha: 0.10);
              }
              return null;
            }),
            onHighlightChanged: (pressed) =>
                setState(() => _isPressed = pressed),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.variant == ButtonVariant.text ? 12 : 20,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: _swapDuration,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: _buildChild(foreground),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    //subtle
    button = AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: button,
    );

    //horizontal shake, three decaying oscillations
    button = AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final t = _shakeController.value;
        final offset = math.sin(t * math.pi * 6) * 8 * (1 - t);
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: button,
    );

    final showMessage =
        _displayStatus == AppButtonStatus.error && widget.errorMessage != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.isFullWidth
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.center,
      children: [
        button,
        AnimatedSize(
          duration: _swapDuration,
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: showMessage
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    widget.errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
