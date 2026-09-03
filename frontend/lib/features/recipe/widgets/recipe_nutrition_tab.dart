import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../core/shared_widgets/Molecules/app_section_header.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/recipe_nutrition.dart';
import '../providers/recipe_nutrition_provider.dart';

enum _NutritionView {
  perRecipe,
  perServing,
}

//complete Nutrition tab displayed inside Recipe Detail
class RecipeNutritionTab extends ConsumerStatefulWidget {
  const RecipeNutritionTab({
    super.key,
    required this.recipeId,
  });

  final int recipeId;

  @override
  ConsumerState<RecipeNutritionTab> createState() => _RecipeNutritionTabState();
}

class _RecipeNutritionTabState extends ConsumerState<RecipeNutritionTab> {
  _NutritionView _selectedView = _NutritionView.perRecipe;

  @override
  Widget build(BuildContext context) {
    final nutritionState = ref.watch(
      recipeNutritionProvider(widget.recipeId),
    );

    return ColoredBox(
      color: AppColors.bgLight,
      child: nutritionState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        error: (error, stackTrace) => _NutritionError(
          message: _nutritionErrorMessage(error),
          onRetry: () {
            ref.invalidate(
              recipeNutritionProvider(widget.recipeId),
            );
          },
        ),
        data: (nutrition) {
          final selectedValues = _selectedView == _NutritionView.perRecipe
              ? nutrition.totals
              : nutrition.perServing;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
            children: [
              Text(
                'Nutritional Information',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${nutrition.servings} servings per recipe',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 18),
              _NutritionViewToggle(
                selectedView: _selectedView,
                onChanged: (view) {
                  setState(() {
                    _selectedView = view;
                  });
                },
              ),
              const SizedBox(height: 20),
              _CalorieSummaryCard(
                calories: selectedValues.caloriesKcal,
                label: _selectedView == _NutritionView.perRecipe
                    ? 'Total recipe calories'
                    : 'Calories per serving',
              ),
              const SizedBox(height: 26),
              const AppSectionHeader(
                title: 'Macronutrients',
                size: SectionHeaderSize.large,
                weight: SectionHeaderWeight.bold,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MacroCard(
                      label: 'Protein',
                      value: selectedValues.proteinG,
                      unit: 'g',
                      icon: Icons.fitness_center_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MacroCard(
                      label: 'Carbs',
                      value: selectedValues.carbsG,
                      unit: 'g',
                      icon: Icons.grain_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MacroCard(
                      label: 'Fat',
                      value: selectedValues.fatG,
                      unit: 'g',
                      icon: Icons.water_drop_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const AppSectionHeader(
                title: 'Other Nutrients',
                size: SectionHeaderSize.large,
                weight: SectionHeaderWeight.bold,
              ),
              const SizedBox(height: 14),
              _SecondaryNutrientRow(
                label: 'Fibre',
                value: selectedValues.fibreG,
                unit: 'g',
                icon: Icons.eco_outlined,
              ),
              const SizedBox(height: 10),
              _SecondaryNutrientRow(
                label: 'Sodium',
                value: selectedValues.sodiumMg,
                unit: 'mg',
                icon: Icons.science_outlined,
              ),
              const SizedBox(height: 26),
              AppSectionHeader(
                title: 'Ingredient Breakdown',
                trailing: '${nutrition.ingredients.length} ingredients',
                size: SectionHeaderSize.large,
                weight: SectionHeaderWeight.bold,
              ),
              const SizedBox(height: 6),
              Text(
                'Expand an ingredient to view its contribution.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 14),
              if (nutrition.ingredients.isEmpty)
                const _EmptyIngredients()
              else
                ...nutrition.ingredients.map(
                  (ingredient) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _IngredientNutritionTile(
                      ingredient: ingredient,
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Nutritional information is an estimate and may not be '
                        'completely accurate. Values are based on data provided '
                        'by USDA FoodData Central.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NutritionViewToggle extends StatelessWidget {
  const _NutritionViewToggle({
    required this.selectedView,
    required this.onChanged,
  });

  final _NutritionView selectedView;
  final ValueChanged<_NutritionView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: 'Per Recipe',
              selected: selectedView == _NutritionView.perRecipe,
              onTap: () => onChanged(_NutritionView.perRecipe),
            ),
          ),
          Expanded(
            child: _ToggleOption(
              label: 'Per Serving',
              selected: selectedView == _NutritionView.perServing,
              onTap: () => onChanged(_NutritionView.perServing),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyBold.copyWith(
              color: selected ? AppColors.textDark : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _CalorieSummaryCard extends StatelessWidget {
  const _CalorieSummaryCard({
    required this.calories,
    required this.label,
  });

  final double calories;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.brand,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_outlined,
              color: AppColors.accent,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatNumber(calories),
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.textDark,
                    fontSize: 36,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$label · kcal',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  final String label;
  final double value;
  final String unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.accentMuted,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatNumber(value)}$unit',
            maxLines: 1,
            style: AppTextStyles.title.copyWith(
              color: AppColors.textLight,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryNutrientRow extends StatelessWidget {
  const _SecondaryNutrientRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  final String label;
  final double value;
  final String unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.accentMuted,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyBold.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ),
          Text(
            '${_formatNumber(value)} $unit',
            style: AppTextStyles.bodyBold.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientNutritionTile extends StatelessWidget {
  const _IngredientNutritionTile({
    required this.ingredient,
  });

  final IngredientNutrition ingredient;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: AppColors.divider,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textMuted,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  ingredient.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${_formatNumber(ingredient.values.caloriesKcal)} kcal',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          subtitle: Text(
            '${_formatNumber(ingredient.quantity)} ${ingredient.unit}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          children: [
            const Divider(color: AppColors.divider),
            const SizedBox(height: 8),
            _IngredientValueRow(
              label: 'Protein',
              value: ingredient.values.proteinG,
              unit: 'g',
            ),
            _IngredientValueRow(
              label: 'Carbohydrates',
              value: ingredient.values.carbsG,
              unit: 'g',
            ),
            _IngredientValueRow(
              label: 'Fat',
              value: ingredient.values.fatG,
              unit: 'g',
            ),
            _IngredientValueRow(
              label: 'Fibre',
              value: ingredient.values.fibreG,
              unit: 'g',
            ),
            _IngredientValueRow(
              label: 'Sodium',
              value: ingredient.values.sodiumMg,
              unit: 'mg',
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${ingredient.percentOfRecipeCalories.round()}% '
                'of recipe calories',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accentMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientValueRow extends StatelessWidget {
  const _IngredientValueRow({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final double value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          Text(
            '${_formatNumber(value)} $unit',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyIngredients extends StatelessWidget {
  const _EmptyIngredients();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'No ingredient nutrition is available for this recipe.',
        textAlign: TextAlign.center,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _NutritionError extends StatelessWidget {
  const _NutritionError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Try again',
                style: AppTextStyles.bodyBold.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _nutritionErrorMessage(Object error) {
  if (error is DioException) {
    final statusCode = error.response?.statusCode;

    if (statusCode == 404) {
      //backend intentionally does not distinguish missing, inaccessible,
      //or ingredient-less recipes
      return 'Nutritional information is not available for this recipe.';
    }

    if (statusCode == 400) {
      return 'This recipe could not be used for nutritional calculations.';
    }
  }

  return 'Unable to load nutritional information.';
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(1);
}
