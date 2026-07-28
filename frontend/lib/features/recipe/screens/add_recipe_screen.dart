import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/shared_widgets/Molecules/app_confirm_dialog.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_text_field.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../../vault/providers/vault_provider.dart';
import '../../ingredients/models/ingredient_catalogue_item.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../models/recipe_step.dart';
import '../providers/recipe_provider.dart';
import '../widgets/ingredient_editor_row.dart';
import '../widgets/step_editor_row.dart';
import '../models/unit_of_measurement.dart';

class AddRecipeScreen extends ConsumerStatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController();

  String? _selectedCuisine;
  int? _selectedFolderId;
  bool _publishToGlobal = false;
  bool _showValidation = false;

  final List<_IngredientRowData> _ingredientRows = [_IngredientRowData()];
  final List<_StepRowData> _stepRows = [_StepRowData()];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    for (final r in _ingredientRows) {
      r.dispose();
    }
    for (final s in _stepRows) {
      s.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final valid = _titleController.text.trim().isNotEmpty &&
        _selectedCuisine != null &&
        int.tryParse(_prepTimeController.text) != null &&
        int.tryParse(_cookTimeController.text) != null &&
        int.tryParse(_servingsController.text) != null;
    final startedRows = _ingredientRows.where((r) => r.isStarted).toList();
    final ingredientsValid = startedRows.every((r) => r.isValid);
    final startedSteps = _stepRows.where((s) => s.isStarted).toList();
    final stepsValid = startedSteps.every((s) => s.isValid);

    if (!valid || !ingredientsValid || !stepsValid) {
      setState(() => _showValidation = true);
      return;
    }

    final recipeRepo = ref.read(recipeRepositoryProvider);

    if (_publishToGlobal) {
      final ok = await showAppConfirmDialog(
        context: context,
        title: 'Publish to Global Vault',
        message:
            'This recipe will be added to the Global Vault. Everyone will be able to see it. Are you sure you want to publish it?',
        confirmLabel: 'Publish',
      );
      if (ok != true) return;
    }

    final recipe = Recipe(
      recipeId: 0,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      cuisineType: _selectedCuisine,
      prepTimeMins: int.tryParse(_prepTimeController.text),
      cookingTimeMins: int.tryParse(_cookTimeController.text),
      servingSize: int.tryParse(_servingsController.text),
      isCommunityPublished: _publishToGlobal,
    );

    final created = await ref
        .read(addRecipeProvider.notifier)
        .submit(recipe, folderId: _selectedFolderId);
    if (created == null) return;

    var saveFailed = false;
    final validRows = _ingredientRows.where((r) => r.isValid).toList();
    for (int i = 0; i < validRows.length; i++) {
      final r = validRows[i];
      final ingredient = RecipeIngredient(
        ingId: r.item!.ingId,
        quantity: double.tryParse(r.quantity.text),
        unit: r.unit!,
        sortOrder: i,
      );
      try {
        await recipeRepo.addRecipeIngredient(created.recipeId, ingredient);
      } catch (_) {
        saveFailed = true;
      }
    }

    final validSteps = _stepRows.where((s) => s.isValid).toList();
    for (int i = 0; i < validSteps.length; i++) {
      final step = RecipeStep(
        stepNr: i + 1,
        content: validSteps[i].content.text.trim(),
      );
      try {
        await recipeRepo.addRecipeStep(created.recipeId, step);
      } catch (e) {
        saveFailed = true;
      }
    }

    if (saveFailed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe saved, but some items did not.')),
      );
    }
    if (saveFailed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe saved, but some items did not.')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe saved')),
      );
    }
    ref.read(addRecipeProvider.notifier).reset();
    if (mounted && context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AddRecipeState>(addRecipeProvider, (prev, next) {
      if (next.isSuccess) {
        ref.invalidate(vaultsProvider);
        ref.invalidate(vaultFoldersProvider);
        ref.invalidate(folderRecipesProvider);
        ref.invalidate(privateFoldersProvider);
        ref.invalidate(recipesProvider);
      } else if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    final cuisinesState = ref.watch(cuisineTypesProvider);
    final unitsState = ref.watch(unitsProvider);
    final submissionState = ref.watch(addRecipeProvider);

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
      body: SafeArea(
        child: cuisinesState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => const _AddRecipeError(),
          data: (cuisines) => unitsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => const _AddRecipeError(),
            data: (units) =>
                _buildForm(cuisines, units, submissionState.isSubmitting),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(List<String> cuisines, List<UnitOfMeasurement> units, bool isSubmitting) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        // centered header
        Center(
          child: Column(
            children: [
              Text(
                'Create Recipe',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1
                    .copyWith(color: AppColors.primary, fontSize: 28),
              ),
              const SizedBox(height: 6),
              Text(
                'Add a new recipe to your vault',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        _sectionHeader('Recipe Details'),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Title',
          hint: 'e.g. Saffron-Infused Risotto',
          controller: _titleController,
        ),
        if (_showValidation && _titleController.text.trim().isEmpty)
          const _FieldError('Title is required.'),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Description',
          hint: 'A short summary of the dish',
          controller: _descriptionController,
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        _CuisineSelector(
          cuisines: cuisines,
          selected: _selectedCuisine,
          onSelected: (v) => setState(() => _selectedCuisine = v),
        ),
        if (_showValidation && _selectedCuisine == null)
          const _FieldError('Cuisine is required.'),
        const SizedBox(height: 32),

        _sectionHeader('Time & Servings'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Prep (min)',
                hint: '15',
                controller: _prepTimeController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Cook (min)',
                hint: '30',
                controller: _cookTimeController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Servings',
                hint: '4',
                controller: _servingsController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        if (_showValidation &&
            (int.tryParse(_prepTimeController.text) == null ||
                int.tryParse(_cookTimeController.text) == null ||
                int.tryParse(_servingsController.text) == null))
          const _FieldError('Prep, cook, and servings are all required.'),
        const SizedBox(height: 32),

        _sectionHeader('Save To'),
        const SizedBox(height: 16),
        _FolderDropdown(
          selectedFolderId: _selectedFolderId,
          onChanged: (id) => setState(() => _selectedFolderId = id),
        ),
        const SizedBox(height: 32),

        _sectionHeader('Sharing'),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primary,
          title: Text('Publish to Global Vault',
              style: AppTextStyles.body.copyWith(
                  color: AppColors.textLight, fontWeight: FontWeight.w600)),
          subtitle: Text('Everyone will be able to see this recipe.',
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
          value: _publishToGlobal,
          onChanged: (v) => setState(() => _publishToGlobal = v),
        ),
        const SizedBox(height: 32),

        _sectionHeader('Ingredients'),
        const SizedBox(height: 16),
        for (int i = 0; i < _ingredientRows.length; i++)
          IngredientEditorRow(
            key: ValueKey(_ingredientRows[i]),
            selectedItem: _ingredientRows[i].item,
            quantityController: _ingredientRows[i].quantity,
            units: units,
            selectedUnit: _ingredientRows[i].unit,
            onUnitChanged: (u) => setState(() => _ingredientRows[i].unit = u),
            onItemSelected: (item) =>
                setState(() => _ingredientRows[i].item = item),
            onRemove: () => setState(() {
              if (_ingredientRows.length > 1) {
                _ingredientRows.removeAt(i).dispose();
              }
            }),
            showError: _showValidation &&
                _ingredientRows[i].isStarted &&
                !_ingredientRows[i].isValid,
          ),
        const SizedBox(height: 4),
        _AddRowButton(
          label: 'Add Ingredient',
          onTap: () =>
              setState(() => _ingredientRows.add(_IngredientRowData())),
        ),
        const SizedBox(height: 32),
        _sectionHeader('Preparation Steps'),
        const SizedBox(height: 16),
        for (int i = 0; i < _stepRows.length; i++)
          StepEditorRow(
            key: ValueKey(_stepRows[i]),
            stepNumber: i + 1,
            controller: _stepRows[i].content,
            onRemove: () => setState(() {
              if (_stepRows.length > 1) {
                _stepRows.removeAt(i).dispose();
              }
            }),
            showError: _showValidation &&
                _stepRows[i].isStarted &&
                !_stepRows[i].isValid,
          ),
        const SizedBox(height: 4),
        _AddRowButton(
          label: 'Add Step',
          onTap: () => setState(() => _stepRows.add(_StepRowData())),
        ),
        const SizedBox(height: 36),

        AppButton.primary(
          label: 'Create Recipe',
          onPressed: isSubmitting ? null : _handleSubmit,
          isLoading: isSubmitting,
          isFullWidth: true,
          isRounded: true,
        ),
        const SizedBox(height: 14),
        AppButton.outlined(
          label: 'Cancel',
          onPressed: () => context.pop(),
          isFullWidth: true,
          isRounded: true,
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primary,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 32,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ],
    );
  }
}

// holds one ingredient row's mutable state while composing
class _IngredientRowData {
  IngredientCatalogueItem? item;
  final TextEditingController quantity = TextEditingController();
  String? unit;

  // the user has begun filling this row
  bool get isStarted =>
      item != null || quantity.text.isNotEmpty || unit != null;

  // fully valid for saving
  bool get isValid =>
      item != null && double.tryParse(quantity.text) != null && unit != null;

  void dispose() => quantity.dispose();
}

class _StepRowData {
  final TextEditingController content = TextEditingController();

  bool get isStarted => content.text.trim().isNotEmpty;
  bool get isValid => content.text.trim().isNotEmpty;

  void dispose() => content.dispose();
}

// Private folder dropdown "My Recipes (default)" when nothing is picked
class _FolderDropdown extends ConsumerWidget {
  const _FolderDropdown({
    required this.selectedFolderId,
    required this.onChanged,
  });

  final int? selectedFolderId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(privateFoldersProvider);

    return foldersAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => Text('Could not load folders.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
      data: (folders) => DropdownButtonFormField<int?>(
        initialValue: selectedFolderId,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
        style: AppTextStyles.body.copyWith(color: AppColors.textLight),
        dropdownColor: AppColors.surfaceWhite,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surfaceMuted,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
        ),
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('My Recipes (default)'),
          ),
          for (final f in folders)
            DropdownMenuItem<int?>(
              value: f.folderId,
              child: Text(f.folderName),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _CuisineSelector extends StatelessWidget {
  const _CuisineSelector({
    required this.cuisines,
    required this.selected,
    required this.onSelected,
  });

  final List<String> cuisines;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cuisine',
            style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: selected,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          style: AppTextStyles.body.copyWith(color: AppColors.textLight),
          dropdownColor: AppColors.surfaceWhite,
          hint: Text('Select a cuisine',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceMuted,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
          ),
          items: [
            for (final c in cuisines)
              DropdownMenuItem<String>(
                value: c,
                child: Text(_formatCuisine(c)),
              ),
          ],
          onChanged: onSelected,
        ),
      ],
    );
  }
}

class _FieldError extends StatelessWidget {
  const _FieldError(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(message,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
    );
  }
}

class _AddRowButton extends StatelessWidget {
  const _AddRowButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label,
                style: AppTextStyles.button.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _AddRecipeError extends StatelessWidget {
  const _AddRecipeError();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Unable to load form data.',
          style: AppTextStyles.body.copyWith(color: AppColors.error)),
    );
  }
}

String _formatCuisine(String raw) {
  return raw
      .split('_')
      .map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}')
      .join(' ');
}
