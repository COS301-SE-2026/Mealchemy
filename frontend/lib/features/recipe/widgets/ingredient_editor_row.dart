import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../../ingredients/models/ingredient_catalogue_item.dart';
import '../models/unit_of_measurement.dart';
import '../../ingredients/providers/ingredient_catalogue_provider.dart';
import '../../ingredients/repositories/ingredient_catalogue_repository.dart';

class IngredientEditorRow extends ConsumerStatefulWidget {
  const IngredientEditorRow({
    super.key,
    required this.selectedItem,
    required this.quantityController,
    required this.units,
    required this.selectedUnit,
    required this.onUnitChanged,
    required this.onItemSelected,
    required this.onRemove,
    this.showError = false,
  });

  final IngredientCatalogueItem? selectedItem;
  final TextEditingController quantityController;
  final List<UnitOfMeasurement> units;
  final String? selectedUnit;
  final ValueChanged<String?> onUnitChanged;
  final ValueChanged<IngredientCatalogueItem> onItemSelected;
  final VoidCallback onRemove;
  final bool showError;

  @override
  ConsumerState<IngredientEditorRow> createState() =>
      _IngredientEditorRowState();
}

class _IngredientEditorRowState extends ConsumerState<IngredientEditorRow> {
  String? get _matchedUnit {
    final sel = widget.selectedUnit;
    if (sel == null) return null;
    for (final u in widget.units) {
      if (u.name.toLowerCase() == sel.toLowerCase()) return u.name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // catalogue picker (tap to search)
              Expanded(
                flex: 5,
                child: _CataloguePickerField(
                  selected: widget.selectedItem,
                  onSelected: widget.onItemSelected,
                ),
              ),
              const SizedBox(width: 8),
              // quantity
              Expanded(
                flex: 2,
                child: TextField(
                  controller: widget.quantityController,
                  decoration: _fieldDecoration('Qty'),
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.textLight),
                ),
              ),
              const SizedBox(width: 8),
              // unit
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  initialValue: _matchedUnit,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      size: 18, color: AppColors.primary),
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.textLight),
                  dropdownColor: AppColors.surfaceWhite,
                  hint: Text('Unit',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textMuted)),
                  decoration: _fieldDecoration('Unit'),
                  items: [
                    for (final u in widget.units)
                      DropdownMenuItem<String>(
                        value: u.name,
                        child: Text(u.name, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: widget.onUnitChanged,
                ),
              ),
              // remove
              IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.close, size: 20),
                color: AppColors.textMuted,
                tooltip: 'Remove',
              ),
            ],
          ),
          if (widget.showError)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 2),
              child: Text(
                'Pick an ingredient and enter quantity + unit.',
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: AppColors.surfaceMuted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
      );
}

class _CataloguePickerField extends StatelessWidget {
  const _CataloguePickerField(
      {required this.selected, required this.onSelected});

  final IngredientCatalogueItem? selected;
  final ValueChanged<IngredientCatalogueItem> onSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final picked = await showModalBottomSheet<IngredientCatalogueItem>(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColors.bgLight,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => const _CatalogueSearchSheet(),
        );
        if (picked != null) onSelected(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.search,
                size: 18,
                color:
                    selected == null ? AppColors.textMuted : AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selected?.name ?? 'Search ingredient',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: selected == null
                      ? AppColors.textMuted
                      : AppColors.textLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogueSearchSheet extends ConsumerStatefulWidget {
  const _CatalogueSearchSheet();

  @override
  ConsumerState<_CatalogueSearchSheet> createState() =>
      _CatalogueSearchSheetState();
}

class _CatalogueSearchSheetState extends ConsumerState<_CatalogueSearchSheet> {
  String _query = '';
  bool _isImporting = false;
  String? _importError;

  Future<void> _chooseCategoryAndRetry({
    required String sourceId,
    required String ingredientName,
  }) async {
    try {
      final repository = ref.read(ingredientCatalogueRepositoryProvider);
      final categories = await repository.getCategories();

      if (!mounted) return;

      setState(() => _isImporting = false);

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
        _isImporting = true;
        _importError = null;
      });

      final importedIngredient = await repository.importExternalIngredient(
        sourceId: sourceId,
        categoryId: selectedCategoryId,
      );

      if (!mounted) return;

      Navigator.pop(context, importedIngredient);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isImporting = false;
        _importError = 'Could not import $ingredientName. Try again.';
      });
    }
  }

  Future<void> _selectItem(IngredientCatalogueItem item) async {
    if (!item.requiresImport) {
      Navigator.pop(context, item);
      return;
    }

    final sourceId = item.sourceId;

    if (sourceId == null || sourceId.isEmpty) {
      setState(() {
        _importError = 'This external ingredient cannot be imported.';
      });
      return;
    }

    setState(() {
      _isImporting = true;
      _importError = null;
    });

    try {
      final importedIngredient = await ref
          .read(ingredientCatalogueRepositoryProvider)
          .importExternalIngredient(sourceId: sourceId);

      if (!mounted) return;

      Navigator.pop(context, importedIngredient);
    } on ExternalIngredientCategoryRequiredException catch (error) {
      if (!mounted) return;

      await _chooseCategoryAndRetry(
        sourceId: error.ingredient.sourceId,
        ingredientName: error.ingredient.name,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isImporting = false;
        _importError = 'Could not import this ingredient. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(catalogueSearchProvider(_query));

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SEARCH INGREDIENT',
              style: AppTextStyles.label
                  .copyWith(color: AppColors.accentMuted, letterSpacing: 2)),
          const SizedBox(height: 12),
          TextField(
            autofocus: true,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'e.g. chicken',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_isImporting)
            const LinearProgressIndicator(
              color: AppColors.primary,
            ),
          if (_importError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _importError!,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            height: 320,
            child: resultsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Text('Search failed.',
                  style: AppTextStyles.body.copyWith(color: AppColors.error)),
              data: (items) => items.isEmpty
                  ? Center(
                      child: Text('No matches.',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.textMuted)))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final item = items[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.name,
                              style: AppTextStyles.title
                                  .copyWith(color: AppColors.textLight)),
                          subtitle: Text(
                            item.category ??
                                '${item.sourceApi ?? 'External'} result',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          //external items are imported before leaving the sheet
                          onTap: _isImporting ? null : () => _selectItem(item),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
