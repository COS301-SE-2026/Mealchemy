import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/shared_widgets/Molecules/app_section_header.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_text_field.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/pantry_provider.dart';

//stateless state to consumer widget
class AddIngredientScreen extends ConsumerWidget {
  const AddIngredientScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(ingredientCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        title: const Text('Add Ingredient'),
      ),
      body: SafeArea(
        child: categoriesState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _AddIngredientError(message: '$error'),
          data: (categories) => _AddIngredientContent(categories: categories),
        ),
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
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _selectedCategory = 'produce';
  bool _isOutOfStock = false;
  bool _showValidation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasName = _nameController.text.trim().isNotEmpty;
    final hasQuantity = _quantityController.text.trim().isNotEmpty;
    final hasUnit = _unitController.text.trim().isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Text(
          'PANTRY ENTRY',
          style: AppTextStyles.label.copyWith(
            color: AppColors.primary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Add Ingredient\nManually',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primary,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Capture the ingredient details you have on hand. This will later help Mealchemy match recipes to your pantry.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textMuted,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 32),

        //ingredients
        const AppSectionHeader(title: 'Ingredient Details'),
        const SizedBox(height: 14),
        AppTextField(
          controller: _nameController,
          label: 'Ingredient name',
          hint: 'e.g. Chicken breast',
          onChanged: (_) => setState(() {}),
        ),
        if (_showValidation && !hasName)
          const _ValidationText('Ingredient name is required.'),
        const SizedBox(height: 14),
        _CategorySelector(
          categories: widget.categories,
          selectedCategory: _selectedCategory,
          onSelected: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
        ),
        const SizedBox(height: 28),

        //amount and units
        const AppSectionHeader(title: 'Quantity'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _quantityController,
                label: 'Quantity',
                hint: 'e.g. 800',
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: _unitController,
                label: 'Unit',
                hint: 'g, ml, cups',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (_showValidation && (!hasQuantity || !hasUnit))
          const _ValidationText('Quantity and unit are required.'),
        const SizedBox(height: 28),

        //purchase details
        const AppSectionHeader(title: 'Purchase Info'),
        const SizedBox(height: 14),
        AppTextField(
          controller: _priceController,
          label: 'Price paid',
          hint: 'e.g. 89.99',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.payments_outlined,
          onChanged: (_) {},
        ),
        const SizedBox(height: 28),
        _StockToggle(
          value: _isOutOfStock,
          onChanged: (value) {
            setState(() {
              _isOutOfStock = value;
            });
          },
        ),
        const SizedBox(height: 36),
        AppButton(
          label: 'Save Ingredient',
          onPressed: _saveIngredient,
        ),
        const SizedBox(height: 14),
        AppButton(
          label: 'Cancel',
          onPressed: () => context.pop(),
        ),
      ],
    );
  }

  void _saveIngredient() {
    final hasRequiredFields = _nameController.text.trim().isNotEmpty &&
        _quantityController.text.trim().isNotEmpty &&
        _unitController.text.trim().isNotEmpty;

    if (!hasRequiredFields) {
      setState(() {
        _showValidation = true;
      });
      return;
    }

    ref.read(pantryStateProvider.notifier).addIngredient(
          name: _nameController.text,
          quantity: _quantityController.text,
          unit: _unitController.text,
          category: _selectedCategory,
          isOutOfStock: _isOutOfStock,
        );

    context.pop();
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final selected = category == selectedCategory;

            return ChoiceChip(
              label: Text(category.toUpperCase()),
              selected: selected,
              onSelected: (_) => onSelected(category),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceLight,
              labelStyle: AppTextStyles.label.copyWith(
                color: selected ? AppColors.textDark : AppColors.textLight,
                letterSpacing: 0.5,
              ),
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.divider,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StockToggle extends StatelessWidget {
  const _StockToggle({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      title: Text(
        'Mark as out of stock',
        style: AppTextStyles.body.copyWith(
          color: AppColors.textLight,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        'Use this when the item should stay listed but not count as available.',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textMuted,
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