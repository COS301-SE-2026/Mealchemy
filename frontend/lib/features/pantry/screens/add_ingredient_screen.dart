import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/shared_widgets/Molecules/app_section_header.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_text_field.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/ingredient_catalogue_item.dart';
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
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: _AddIngredientContent(),
    );
  }
}

class _AddIngredientContent extends ConsumerStatefulWidget {
  const _AddIngredientContent();

  @override
  ConsumerState<_AddIngredientContent> createState() =>
      _AddIngredientContentState();
}

class _AddIngredientContentState extends ConsumerState<_AddIngredientContent> {
  final TextEditingController _nameController = TextEditingController();

  List<IngredientCatalogueItem> _ingredientOptions = [];

  IngredientCatalogueItem? _selectedIngredient;
  bool _isSearchingIngredients = false;
  String? _ingredientSearchError;

  int _searchRequestId = 0;

  //stepper starts at 1 so quantity can never be zero or negative
  int _quantity = 1;
  String? _selectedUnit;
  bool _showValidation = false;

  AppButtonStatus _saveStatus = AppButtonStatus.idle;
  String? _saveError;

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
                  hint: 'Search catalogue, e.g. Chicken Breast',
                  prefixIcon: Icons.search,
                  onChanged: _onSearchChanged,
                ),
                if (_showValidation && !hasName)
                  const _ValidationText('Ingredient name is required.'),
                if (_showValidation && _selectedIngredient == null && hasName)
                  const _ValidationText(
                    'Please select an ingredient from the catalogue.',
                  ),
                if (_ingredientSearchError != null)
                  _ValidationText(_ingredientSearchError!),
                if (_isSearchingIngredients)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: LinearProgressIndicator(),
                  ),
                if (_ingredientOptions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _IngredientSearchResults(
                    ingredients: _ingredientOptions,
                    selectedIngredient: _selectedIngredient,
                    onSelected: _onIngredientSelected,
                  ),
                ],
                const SizedBox(height: 14),
                _SelectedCategoryLabel(
                  category:
                      _selectedIngredient?.category ?? 'Select an ingredient',
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
                  status: _saveStatus,
                  errorMessage: _saveError,
                  //pop only after the tick has played
                  onSuccessComplete: () => context.pop(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  //searches the catalogue as the user types; typing invalidates any prior
  //selection so save can't file a stale ing_id
  Future<void> _onSearchChanged(String value) async {
    final query = value.trim();
    final requestId = ++_searchRequestId;

    setState(() {
      _selectedIngredient = null;
      _ingredientSearchError = null;
    });

    if (query.isEmpty) {
      setState(() {
        _ingredientOptions = [];
        _isSearchingIngredients = false;
      });
      return;
    }

    setState(() => _isSearchingIngredients = true);

    try {
      final results = await ref
          .read(ingredientCatalogueRepositoryProvider)
          .searchIngredients(query);

      //ignore responses that arrived after a newer query went out
      if (!mounted || requestId != _searchRequestId) return;

      setState(() {
        _ingredientOptions = results;
        _isSearchingIngredients = false;
      });
    } catch (error) {
      if (!mounted || requestId != _searchRequestId) return;

      setState(() {
        _ingredientOptions = [];
        _isSearchingIngredients = false;
        _ingredientSearchError = 'Could not search the catalogue. Try again.';
      });
    }
  }

  //locks in a catalogue ingredient so save files its real ing_id
  void _onIngredientSelected(IngredientCatalogueItem item) {
    setState(() {
      _selectedIngredient = item;
      _nameController.text = item.name;
      _ingredientOptions = [];
    });
  }

  Future<void> _saveIngredient() async {
    final selectedIngredientId = _selectedIngredient?.ingId;

    final hasRequiredFields = selectedIngredientId != null &&
        _nameController.text.trim().isNotEmpty &&
        _selectedUnit != null;

    if (!hasRequiredFields) {
      setState(() {
        _showValidation = true;
        _saveStatus = AppButtonStatus.error;
        _saveError = null;
      });
      return;
    }

    setState(() {
      _saveStatus = AppButtonStatus.loading;
      _saveError = null;
    });

    try {
      await ref.read(pantryStateProvider.notifier).addIngredient(
            ingId: selectedIngredientId,
            quantity: '$_quantity',
            unit: _selectedUnit!,
          );
      if (!mounted) return;
      setState(() => _saveStatus = AppButtonStatus.success);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saveStatus = AppButtonStatus.error;
        _saveError = 'Could not save ingredient. Try again.';
      });
    }
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

class _IngredientSearchResults extends StatelessWidget {
  const _IngredientSearchResults({
    required this.ingredients,
    required this.selectedIngredient,
    required this.onSelected,
  });

  final List<IngredientCatalogueItem> ingredients;
  final IngredientCatalogueItem? selectedIngredient;
  final ValueChanged<IngredientCatalogueItem> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ingredients.map((ingredient) {
        final selected = selectedIngredient?.ingId == ingredient.ingId;
        return Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(
              selected ? Icons.check_circle : Icons.restaurant_outlined,
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),
            title: Text(
              ingredient.name,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              _formatCategory(
                ingredient.category ??
                    '${ingredient.sourceApi ?? 'External'} result',
              ),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            //external results must be imported before they can be selected
            onTap:
                ingredient.requiresImport ? null : () => onSelected(ingredient),
          ),
        );
      }).toList(),
    );
  }
}

class _SelectedCategoryLabel extends StatelessWidget {
  const _SelectedCategoryLabel({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.category_outlined,
          color: AppColors.primary,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          'Category: ${_formatCategory(category)}',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textLight,
          ),
        ),
      ],
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
  });

  final String label;
  final String hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

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
                child: Text(option),
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
