import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/shared_widgets/Molecules/app_section_header.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/shared_widgets/atoms/app_card.dart';
import '../../../core/shared_widgets/atoms/app_chip.dart';
import '../../../core/shared_widgets/atoms/app_text_field.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

//need consumer state widget for textediting controller and submission state needs consumer state
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    final recipe = Recipe(
      //place holder value 0, backend will generate value when inserting
      recipeId: 0,
      title: title,
      description: description.isEmpty ? null : description,
      cuisineType: _selectedCuisine,
      prepTimeMins: int.tryParse(_prepTimeController.text),
      cookingTimeMins: int.tryParse(_cookTimeController.text),
      servingSize: int.tryParse(_servingsController.text),
    );

    ref.read(addRecipeProvider.notifier).submit(recipe);
  }

  @override
  Widget build(BuildContext context) {
    //runs on every state change allows form to stays stateless
    ref.listen<AddRecipeState>(addRecipeProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe saved')),
        );
        //reset clears isSucess
        ref.read(addRecipeProvider.notifier).reset();
        if (context.canPop()) context.pop();
      } else if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    final cuisinesState = ref.watch(cuisineTypesProvider);
    final submissionState = ref.watch(addRecipeProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        title: const Text('Add Recipe'),
      ),
      //error if cusines type fails to load
      body: SafeArea(
        child: cuisinesState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _AddRecipeError(message: '$error'),
          data: (cuisines) => _AddRecipeContent(
            cuisines: cuisines,
            titleController: _titleController,
            descriptionController: _descriptionController,
            prepTimeController: _prepTimeController,
            cookTimeController: _cookTimeController,
            servingsController: _servingsController,
            selectedCuisine: _selectedCuisine,
            onCuisineSelected: (value) => setState(() => _selectedCuisine = value),
            onSubmit: _handleSubmit,
            isSubmitting: submissionState.isSubmitting,
          ),
        ),
      ),
    );
  }
}

class _AddRecipeContent extends StatelessWidget {
  const _AddRecipeContent({
    required this.cuisines,
    required this.titleController,
    required this.descriptionController,
    required this.prepTimeController,
    required this.cookTimeController,
    required this.servingsController,
    required this.selectedCuisine,
    required this.onCuisineSelected,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final List<String> cuisines;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController prepTimeController;
  final TextEditingController cookTimeController;
  final TextEditingController servingsController;
  final String? selectedCuisine;
  final ValueChanged<String?> onCuisineSelected;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Text(
          'NEW RECIPE',
          style: AppTextStyles.label.copyWith(
            color: AppColors.primary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Add a Recipe\nto Your Vault',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primary,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Capture the essentials now - ingredients and steps can be added on the editor screen in the next iteration.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textMuted,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 32),

        //Recipe details
        const AppSectionHeader(title: 'Recipe Details'),
        const SizedBox(height: 14),
        AppTextField(
          label: 'Title',
          hint: 'e.g. Saffron-Infused Risotto',
          controller: titleController,
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: 'Description',
          hint: 'A short summary of the dish',
          controller: descriptionController,
          maxLines: 3,
        ),
        const SizedBox(height: 18),
        _CuisineSelector(
          cuisines: cuisines,
          selected: selectedCuisine,
          onSelected: onCuisineSelected,
        ),
        const SizedBox(height: 22),
        const _PhotoUploadTile(),
        const SizedBox(height: 28),

        //Time and servings
        const AppSectionHeader(title: 'Time & Servings'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Prep (min)',
                hint: '15',
                controller: prepTimeController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Cook (min)',
                hint: '30',
                controller: cookTimeController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Servings',
                hint: '4',
                controller: servingsController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        //Ingredients placeholder
        const AppSectionHeader(title: 'Ingredients'),
        const SizedBox(height: 14),
        const _ComingSoonCard(
          icon: Icons.list_alt_outlined,
          message: 'Ingredient editor coming soon.',
        ),
        const SizedBox(height: 28),

        //Steps placeholder
        const AppSectionHeader(title: 'Preparation Steps'),
        const SizedBox(height: 14),
        const _ComingSoonCard(
          icon: Icons.format_list_numbered,
          message: 'Step-by-step editor coming soon.',
        ),
        const SizedBox(height: 36),

        AppButton.primary(
          label: 'Save Recipe',
          onPressed: isSubmitting ? null : onSubmit,
          isLoading: isSubmitting,
          isFullWidth: true,
        ),
        const SizedBox(height: 14),
        AppButton.outlined(
          label: 'Cancel',
          onPressed: () => context.pop(),
          isFullWidth: true,
        ),
      ],
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
        Text(
          'Cuisine',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cuisines
              .map(
                (cuisine) => AppChip(
                  label: _formatCuisine(cuisine),
                  selected: cuisine == selected,
                  //tap again to deselect
                  onTap: () => onSelected(cuisine == selected ? null : cuisine),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

//no upload feature yet
class _PhotoUploadTile extends StatelessWidget {
  const _PhotoUploadTile();

  @override
  Widget build(BuildContext context) {
    return AppCard.outlined(
      onTap: () {},
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.accentMuted,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hero photo',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap to upload an image of the dish',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard.outlined(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      customBorderColor: AppColors.divider,
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddRecipeError extends StatelessWidget {
  const _AddRecipeError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Unable to load form data.',
        style: AppTextStyles.body.copyWith(color: AppColors.error),
      ),
    );
  }
}

//formatted version ui only. enum value is stored internally
String _formatCuisine(String raw) {
  
  return raw
      .split('_')
      .map((part) => part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
