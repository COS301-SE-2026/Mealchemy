import 'package:flutter/material.dart';

import '../../theme/app_colours.dart';
import '../../theme/app_typography.dart';

//shared styles for the text inputs
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      maxLines: maxLines,
      style: AppTextStyles.body.copyWith(color: AppColors.textLight),
      //uses app theme tokens for consistent inputs
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        //search and form inputs support
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: AppColors.textMuted),
        suffixIcon: suffixIcon,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textMuted,
        ),
        hintStyle: AppTextStyles.body.copyWith(
          color: AppColors.textMuted,
          fontStyle: FontStyle.italic,
        ),
        filled: true,
        fillColor: AppColors.bgLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.4,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}