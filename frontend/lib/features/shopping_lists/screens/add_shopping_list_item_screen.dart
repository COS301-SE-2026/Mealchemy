import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../../../core/shared_widgets/Molecules/app_section_header.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_text_field.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../../pantry/models/ingredient_catalogue_item.dart';
import '../../pantry/providers/pantry_provider.dart';
import '../providers/shopping_list_provider.dart';
import '../../pantry/repositories/ingredient_catalogue_repository.dart';

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

enum _ItemEntryMode {
  catalogue,
  custom,
}

class AddShoppingListItemScreen extends ConsumerStatefulWidget {
  const AddShoppingListItemScreen({
    super.key,
    required this.listId,
  });

  final String listId;

  @override
  ConsumerState<AddShoppingListItemScreen> createState() =>
      _AddShoppingListItemScreenState();
}

class _AddShoppingListItemScreenState
    extends ConsumerState<AddShoppingListItemScreen> {
  final _catalogueController = TextEditingController();
  final _customNameController = TextEditingController();
  final _quantityController = TextEditingController();

  _ItemEntryMode _mode = _ItemEntryMode.catalogue;
  IngredientCatalogueItem? _selectedIngredient;
  List<IngredientCatalogueItem> _ingredientOptions = [];

  String? _selectedUnit;
  String? _identityError;
  String? _quantityError;
  String? _unitError;
  String? _searchError;

  bool _isSearching = false;
  int _searchRequestId = 0;

  AppButtonStatus _saveStatus = AppButtonStatus.idle;
  String? _saveError;

  @override
  void dispose() {
    _catalogueController.dispose();
    _customNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly = ref.watch(offlineReadOnlyProvider);
    if (isReadOnly) {
      return Scaffold(
        backgroundColor: AppColors.bgLight,
        appBar: AppBar(
          backgroundColor: AppColors.bgLight,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            tooltip: 'Back',
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Changes are unavailable offline',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your shopping lists are still available to view.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: AppColors.bgCream,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          'Shopping List Entry',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              'Add Shopping List Item',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose from the catalogue or add your own custom item',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 28),
            const AppSectionHeader(title: 'Item Type'),
            const SizedBox(height: 14),
            _ItemModeSelector(
              selectedMode: _mode,
              onSelected: _changeMode,
            ),
            const SizedBox(height: 28),
            const AppSectionHeader(title: 'Item Details'),
            const SizedBox(height: 14),
            if (_mode == _ItemEntryMode.catalogue)
              _buildCatalogueFields()
            else
              _buildCustomItemFields(),
            const SizedBox(height: 28),
            const AppSectionHeader(title: 'Quantity'),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _quantityController,
                    label: 'Quantity',
                    hint: 'e.g. 1.5',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    errorText: _quantityError,
                    onChanged: (_) {
                      if (_quantityError == null) return;
                      setState(() => _quantityError = null);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _UnitDropdown(
                    value: _selectedUnit,
                    errorText: _unitError,
                    onChanged: (value) {
                      setState(() {
                        _selectedUnit = value;
                        _unitError = null;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            AppButton.primary(
              label: 'Add Item',
              onPressed: _saveItem,
              isFullWidth: true,
              isRounded: true,
              status: _saveStatus,
              errorMessage: _saveError,
              onSuccessComplete: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogueFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _catalogueController,
          label: 'Ingredient Name',
          hint: 'Search catalogue, e.g. Chicken Breast',
          prefixIcon: Icons.search,
          errorText: _identityError,
          onChanged: _searchCatalogue,
        ),
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: LinearProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        if (_searchError != null) _InlineError(message: _searchError!),
        if (_ingredientOptions.isNotEmpty) ...[
          const SizedBox(height: 10),
          _CatalogueResults(
            ingredients: _ingredientOptions,
            onSelected: _selectIngredient,
          ),
        ],
        const SizedBox(height: 14),
        _CategoryLabel(
          category: _selectedIngredient?.category ?? 'Select an ingredient',
        ),
      ],
    );
  }

  Widget _buildCustomItemFields() {
    return AppTextField(
      controller: _customNameController,
      label: 'Custom Item Name',
      hint: 'e.g. Cupcakes',
      prefixIcon: Icons.edit_outlined,
      errorText: _identityError,
      onChanged: (_) {
        if (_identityError == null) return;
        setState(() => _identityError = null);
      },
    );
  }

  void _changeMode(_ItemEntryMode mode) {
    if (_mode == mode) return;

    setState(() {
      _mode = mode;
      _selectedIngredient = null;
      _ingredientOptions = [];
      _catalogueController.clear();
      _customNameController.clear();
      _identityError = null;
      _searchError = null;
      _isSearching = false;
      _searchRequestId++;
    });
  }

  Future<void> _searchCatalogue(String value) async {
    final query = value.trim();
    final requestId = ++_searchRequestId;

    setState(() {
      _selectedIngredient = null;
      _identityError = null;
      _searchError = null;
    });

    if (query.isEmpty) {
      setState(() {
        _ingredientOptions = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await ref
          .read(ingredientCatalogueRepositoryProvider)
          .searchIngredients(query);

      // Ignore an old response if the user has already typed a newer query.
      if (!mounted || requestId != _searchRequestId) return;

      setState(() {
        _ingredientOptions = results;
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted || requestId != _searchRequestId) return;

      setState(() {
        _ingredientOptions = [];
        _isSearching = false;
        _searchError = 'Could not search the catalogue. Try again.';
      });
    }
  }

  Future<void> _selectIngredient(
    IngredientCatalogueItem ingredient,
  ) async {
    if (!ingredient.requiresImport) {
      _setSelectedIngredient(ingredient);
      return;
    }

    final sourceId = ingredient.sourceId;

    if (sourceId == null || sourceId.isEmpty) {
      setState(() {
        _searchError =
            'This external ingredient cannot be imported. Try another item.';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final importedIngredient = await ref
          .read(ingredientCatalogueRepositoryProvider)
          .importExternalIngredient(sourceId: sourceId);

      if (!mounted) return;

      _setSelectedIngredient(importedIngredient);
    } on ExternalIngredientCategoryRequiredException catch (error) {
      if (!mounted) return;

      await _chooseCategoryAndRetry(
        sourceId: error.ingredient.sourceId,
        ingredientName: error.ingredient.name,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
        _searchError = 'Could not import this ingredient. Try again.';
      });
    }
  }

  Future<void> _chooseCategoryAndRetry({
    required String sourceId,
    required String ingredientName,
  }) async {
    try {
      final repository = ref.read(ingredientCatalogueRepositoryProvider);
      final categories = await repository.getCategories();

      if (!mounted) return;

      setState(() => _isSearching = false);

      final selectedCategoryId = await showDialog<int>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Choose a category'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: categories
                    .map(
                      (category) => ListTile(
                        title: Text(category.name),
                        onTap: () => Navigator.of(dialogContext).pop(
                          category.categoryId,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );

      if (!mounted || selectedCategoryId == null) return;

      setState(() {
        _isSearching = true;
        _searchError = null;
      });

      final importedIngredient = await repository.importExternalIngredient(
        sourceId: sourceId,
        categoryId: selectedCategoryId,
      );

      if (!mounted) return;

      _setSelectedIngredient(importedIngredient);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
        _searchError = 'Could not import $ingredientName. Try again.';
      });
    }
  }

  void _setSelectedIngredient(IngredientCatalogueItem ingredient) {
    setState(() {
      _selectedIngredient = ingredient;
      _catalogueController.text = ingredient.name;
      _ingredientOptions = [];
      _identityError = null;
      _searchError = null;
      _isSearching = false;
    });
  }

  Future<void> _saveItem() async {
    final quantityText = _quantityController.text.trim();
    final parsedQuantity = num.tryParse(quantityText);
    final customName = _customNameController.text.trim();
    final selectedIngredientId = _selectedIngredient?.ingId;

    final hasValidIdentity = _mode == _ItemEntryMode.catalogue
        ? selectedIngredientId != null
        : customName.isNotEmpty;

    final hasValidQuantity = parsedQuantity != null && parsedQuantity > 0;
    final hasUnit = _selectedUnit != null;

    if (!hasValidIdentity || !hasValidQuantity || !hasUnit) {
      setState(() {
        _identityError = hasValidIdentity
            ? null
            : _mode == _ItemEntryMode.catalogue
                ? 'Please select an ingredient from the catalogue.'
                : 'Custom item name is required.';
        _quantityError =
            hasValidQuantity ? null : 'Enter a quantity greater than zero.';
        _unitError = hasUnit ? null : 'Unit is required.';
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
      //browser refresh may open screen before the detail screen has loaded shopping-list state
      await ref.read(shoppingListsProvider.future);

      await ref.read(shoppingListsProvider.notifier).addItemToList(
            listId: widget.listId,
            ingId:
                _mode == _ItemEntryMode.catalogue ? selectedIngredientId : null,
            name: _mode == _ItemEntryMode.custom ? customName : null,
            quantity: quantityText,
            // The provider currently calls this category for legacy reasons,
            // but it is the unit sent to the backend.
            category: _selectedUnit!,
          );

      if (!mounted) return;
      setState(() => _saveStatus = AppButtonStatus.success);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saveStatus = AppButtonStatus.error;
        _saveError = 'Could not add the item. Try again.';
      });
    }
  }
}

class _ItemModeSelector extends StatelessWidget {
  const _ItemModeSelector({
    required this.selectedMode,
    required this.onSelected,
  });

  final _ItemEntryMode selectedMode;
  final ValueChanged<_ItemEntryMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeButton(
            label: 'Catalogue',
            icon: Icons.search,
            selected: selectedMode == _ItemEntryMode.catalogue,
            onTap: () => onSelected(_ItemEntryMode.catalogue),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ModeButton(
            label: 'Custom Item',
            icon: Icons.edit_outlined,
            selected: selectedMode == _ItemEntryMode.custom,
            onTap: () => onSelected(_ItemEntryMode.custom),
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? AppColors.textDark : AppColors.primary,
        backgroundColor: selected ? AppColors.primary : Colors.transparent,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _CatalogueResults extends StatelessWidget {
  const _CatalogueResults({
    required this.ingredients,
    required this.onSelected,
  });

  final List<IngredientCatalogueItem> ingredients;
  final ValueChanged<IngredientCatalogueItem> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ingredients.map((ingredient) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.restaurant_outlined,
            color: AppColors.primary,
          ),
          title: Text(
            ingredient.name,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            ingredient.category ??
                '${ingredient.sourceApi ?? 'External'} result',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          //external results imported before being selected
          onTap: () => onSelected(ingredient),
        );
      }).toList(),
    );
  }
}

class _CategoryLabel extends StatelessWidget {
  const _CategoryLabel({
    required this.category,
  });

  final String category;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.category_outlined,
          size: 18,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          'Category: $category',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _UnitDropdown extends StatelessWidget {
  const _UnitDropdown({
    required this.value,
    required this.errorText,
    required this.onChanged,
  });

  final String? value;
  final String? errorText;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unit',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          hint: Text(
            'Select unit',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          decoration: InputDecoration(
            errorText: errorText,
            filled: true,
            fillColor: AppColors.surfaceMuted,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
          items: _unitOptions.map((unit) {
            return DropdownMenuItem<String>(
              value: unit,
              child: Text(unit),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
        ),
      ),
    );
  }
}
