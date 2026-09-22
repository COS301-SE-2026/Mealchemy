import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/recipe/providers/recipe_provider.dart';
import '../../theme/app_colours.dart';
import '../../theme/app_typography.dart';

class AppUnitDropdown extends ConsumerWidget {
  const AppUnitDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Unit',
    this.hint = 'Select unit',
    this.errorText,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String? label;
  final String hint;
  final String? errorText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitOptionsProvider);
    final safeValue = units.any((u) => u.name == value) ? value : null;

    final field = DropdownButtonFormField<String>(
      initialValue: safeValue,
      isExpanded: true,
      dropdownColor: AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(16),
      menuMaxHeight: 5 * 48.0,
      elevation: 3,
      icon: const Icon(
        Icons.keyboard_arrow_down,
        size: 18,
        color: AppColors.primary,
      ),
      hint: Text(
        hint,
        style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
      ),
      style: AppTextStyles.body.copyWith(color: AppColors.textLight),
      decoration: InputDecoration(
        errorText: errorText,
        isDense: true,
        filled: true,
        fillColor: AppColors.surfaceMuted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      items: units
          .map((u) => DropdownMenuItem(
                value: u.name,
                child: Text(u.name, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: onChanged,
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}
