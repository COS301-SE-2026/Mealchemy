import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/recipe_ingredient.dart';
import '../providers/recipe_provider.dart';
import '../utils/serving_scaler.dart';

//a row in the ingredients list, amount scales with the chosen serving count
class RecipeIngredientRow extends ConsumerWidget {
  const RecipeIngredientRow({
    super.key,
    required this.ingredient,
    required this.recipeId,
    required this.baseServings,
  });

  final RecipeIngredient ingredient;
  final int recipeId;
  final int baseServings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stored = ref.watch(servingsProvider(recipeId));
    final servings = stored == 0 ? baseServings : stored;
    final factor = baseServings > 0 ? servings / baseServings : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(radius: 4, backgroundColor: AppColors.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              ingredient.name ?? 'Ingredient #${ingredient.ingId}',
              style: AppTextStyles.body.copyWith(color: AppColors.textLight),
            ),
          ),
          if (ingredient.quantity != null)
            Text(
              formatScaledQuantity(
                quantity: ingredient.quantity!,
                unit: ingredient.unit,
                factor: factor,
              ),
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}