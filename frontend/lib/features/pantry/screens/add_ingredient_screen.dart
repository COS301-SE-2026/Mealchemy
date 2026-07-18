import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/shared_widgets/Molecules/app_section_header.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_text_field.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/pantry_provider.dart';

const double _blurArea = 240;
const double _sheetTop = 212;

//units for the unit dropdown
//need to be made dynamic in the future to support custom units and unit conversion
const List<String> _unitOptions = [
  'g',
  'kg',
  'ml',
  'L',
  'cups',
  'tbsp',
  'tsp',
  'oz',
  'pcs',
];

class AddIngredientScreen extends ConsumerWidget {
  const AddIngredientScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(ingredientCategoriesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: categoriesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _AddIngredientError(message: '$error'),
        data: (categories) => _AddIngredientContent(categories: categories),
      ),
    );
  }
}

class _AddIngredientContent extends ConsumerStatefulWidget {
  const _AddIngredientContent({required this.categories});

  final List<String> categories;

  @override
  ConsumerState<_AddIngredientContent> createState() =>
      _AddIngredientContentState();
}

class _AddIngredientContentState extends ConsumerState<_AddIngredientContent> {
  final TextEditingController _nameController = TextEditingController();

  //stepper starts at 1 so quantity can never be zero or negatve
  int _quantity = 1;
  String? _selectedUnit;
  String? _selectedCategory;
  bool _showValidation = false;

  @override
  void initState() {
    super.initState();
    if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasName = _nameController.text.trim().isNotEmpty;
    final hasUnit = _selectedUnit != null;

    return Stack(
      children: [
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: _blurArea,
          child: _PantryHeader(),
        ),
        Positioned.fill(
          top: _sheetTop,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.bgCream,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              children: [
                const Align(
                  alignment: Alignment.topCenter,
                  child: _SheetHandle(),
                ),
                const SizedBox(height: 16),

                Text(
                  'Pantry Entry',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add Ingredient Manually',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 26),

                //ingredient details
                const AppSectionHeader(title: 'Ingredient Details'),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _nameController,
                  label: 'Ingredient Name',
                  hint: 'e.g. Chicken Breast',
                  prefixIcon: Icons.search,
                  onChanged: (_) => setState(() {}),
                ),
                if (_showValidation && !hasName)
                  const _ValidationText('Ingredient name is required.'),
                const SizedBox(height: 14),
                _LabelledDropdown(
                  label: 'Category',
                  hint: 'Select a category',
                  value: _selectedCategory,
                  options: widget.categories,
                  displayText: _formatCategory,
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                ),
                const SizedBox(height: 28),

                //quantity
                const AppSectionHeader(title: 'Quantity'),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _LabelledField(
                        label: 'Quantity',
                        child: _QuantityStepper(
                          value: _quantity,
                          onChanged: (value) =>
                              setState(() => _quantity = value),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LabelledDropdown(
                        label: 'Unit',
                        hint: 'e.g. oz',
                        value: _selectedUnit,
                        options: _unitOptions,
                        onChanged: (value) =>
                            setState(() => _selectedUnit = value),
                      ),
                    ),
                  ],
                ),
                if (_showValidation && !hasUnit)
                  const _ValidationText('Unit is required.'),
                const SizedBox(height: 36),

                AppButton.primary(
                  label: 'Save Ingredient',
                  onPressed: _saveIngredient,
                  isFullWidth: true,
                  isRounded: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _saveIngredient() {
    final hasRequiredFields =
        _nameController.text.trim().isNotEmpty && _selectedUnit != null;

    if (!hasRequiredFields) {
      setState(() {
        _showValidation = true;
      });
      return;
    }

    ref.read(pantryStateProvider.notifier).addIngredient(
          name: _nameController.text,
          quantity: '$_quantity',
          unit: _selectedUnit!,
          category: _selectedCategory ?? 'produce',
          isOutOfStock: false,
        );

    context.pop();
  }
}

String _formatCategory(String raw) {
  if (raw.isEmpty) return raw;
  return raw[0].toUpperCase() + raw.substring(1);
}

class _PantryHeader extends StatelessWidget {
  const _PantryHeader();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _blurArea,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: const DecoratedBox(
                decoration: BoxDecoration(color: AppColors.overlayLight),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderCircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => context.pop(),
                    background: AppColors.textMuted.withValues(alpha: 0.45),
                    iconColor: AppColors.textDark,
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _HeaderCircleButton(
                        icon: Icons.add,
                        onTap: () {},
                        background: AppColors.textMuted.withValues(alpha: 0.25),
                        iconColor: AppColors.primary,
                      ),
                      const SizedBox(height: 10),
                      _HeaderCircleButton(
                        icon: Icons.photo_camera_outlined,
                        onTap: () {},
                        background: AppColors.textMuted.withValues(alpha: 0.25),
                        iconColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({
    required this.icon,
    required this.onTap,
    required this.background,
    required this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color background;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: background,
        ),
        child: Icon(icon, color: iconColor, size: 19),
      ),
    );
  }
}

//small pill at the top of the sheet
class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.tertiaryMuted.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _LabelledField extends StatelessWidget {
  const _LabelledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _LabelledDropdown extends StatelessWidget {
  const _LabelledDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
    this.displayText,
  });

  final String label;
  final String hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final String Function(String)? displayText;

  @override
  Widget build(BuildContext context) {
    return _LabelledField(
      label: label,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        onChanged: onChanged,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.primary,
          size: 20,
        ),
        hint: Text(
          hint,
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        ),
        style: AppTextStyles.body.copyWith(color: AppColors.textLight),
        dropdownColor: AppColors.surfaceWhite,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surfaceMuted,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.inputBorder, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.inputBorder, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        items: options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option,
                child: Text(displayText?.call(option) ?? option),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder, width: 1),
      ),
      child: Row(
        children: [
          _StepperButton(
            icon: Icons.remove,
            onTap: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Expanded(
            child: Center(
              child: Text(
                '$value',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 44,
        height: double.infinity,
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? AppColors.textMuted : AppColors.primary,
        ),
      ),
    );
  }
}

class _ValidationText extends StatelessWidget {
  const _ValidationText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),
    );
  }
}

class _AddIngredientError extends StatelessWidget {
  const _AddIngredientError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Unable to load ingredient categories.',
        style: AppTextStyles.body.copyWith(color: AppColors.error),
      ),
    );
  }
}
