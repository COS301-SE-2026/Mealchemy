// Text input fields used across screens
// Standard variant for normal text input
// Private variant for sensitive data like passwords
import 'package:flutter/material.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';

class AppTextField extends StatefulWidget {
  final String hint;
  final String? label;
  final String? errorText;
  final bool hasError;
  final bool isPrivate;
  final bool enabled;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType keyboardType;
  final int maxLines;
  final Color? customColor;
  final Color? customFillColor;

  const AppTextField({
    super.key,
    required this.hint,
    this.label,
    this.errorText,
    this.hasError = false,
    this.isPrivate = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.customColor,
    this.customFillColor,
  });

  //Standard flexible, accepts custom colours
  const AppTextField.standard({
    super.key,
    required this.hint,
    this.label,
    this.errorText,
    this.hasError = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.customColor,
    this.customFillColor,
  }) : isPrivate = false;

  // Private locked, no custom colours for consistency
  const AppTextField.private({
    super.key,
    required this.hint,
    this.label,
    this.errorText,
    this.hasError = false,
    this.enabled = true,
    this.controller,
    this.onChanged,
    this.onSubmitted,
  })  : isPrivate = true,
        keyboardType = TextInputType.visiblePassword,
        maxLines = 1,
        prefixIcon = null,
        suffixIcon = null,
        customColor = null,
        customFillColor = null;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  //Controls whether private text is visible or hidden
  bool _obscureText = true;

  //Controls focus state for border colour change
  bool _isFocused = false;

  // True when either a field message or the border-only flag is set
  bool get _hasError => widget.errorText != null || widget.hasError;

  // Uses customColor if provided otherwise defaults to primary
  Color get _focusColor => widget.customColor ?? AppColors.primary;

  //Border when field is not focused
  OutlineInputBorder get _defaultBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: widget.customColor ?? AppColors.inputBorder,
          width: 1,
        ),
      );

  // Border when field is focused
  OutlineInputBorder get _focusedBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _focusColor, width: 1.5),
      );

  // Border when field has an error
  OutlineInputBorder get _errorBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.errorBorder, width: 1.5),
      );

  // Border when field is disabled
  OutlineInputBorder get _disabledBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.divider.withValues(alpha: 0.5),
          width: 1,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        //Label above the field
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: _hasError
                  ? AppColors.error
                  : (_isFocused ? _focusColor : AppColors.textLight),
            ),
          ),
          const SizedBox(height: 6),
        ],

        //Input field
        Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: TextField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            obscureText: widget.isPrivate && _obscureText,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            maxLines: widget.isPrivate ? 1 : widget.maxLines,
            style: AppTextStyles.body.copyWith(
              color: widget.enabled ? AppColors.textLight : AppColors.textMuted,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: widget.enabled
                  ? (widget.customFillColor ?? AppColors.surfaceMuted)
                  : AppColors.surfaceLight,
              border: _hasError ? _errorBorder : _defaultBorder,
              enabledBorder: _hasError ? _errorBorder : _defaultBorder,
              focusedBorder: _hasError ? _errorBorder : _focusedBorder,
              errorBorder: _errorBorder,
              focusedErrorBorder: _errorBorder,
              disabledBorder: _disabledBorder,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              //Optional prefix icon
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      size: 18,
                      color: _isFocused ? _focusColor : AppColors.textMuted,
                    )
                  : null,
              //Toggle icon for private fields only
              suffixIcon: widget.isPrivate
                  ? GestureDetector(
                      onTap: () => setState(() => _obscureText = !_obscureText),
                      child: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    )
                  : widget.suffixIcon,
            ),
          ),
        ),

        //Error message, aligned to the field's left edge with breathing room
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              widget.errorText!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ],
    );
  }
}