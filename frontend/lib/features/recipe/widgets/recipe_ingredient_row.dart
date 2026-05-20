import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/recipe_ingredient.dart';

//a row in the ingredients list
class RecipeIngredientRow extends StatelessWidget {
  const RecipeIngredientRow({super.key, required this.ingredient});

  final RecipeIngredient ingredient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(radius: 4, backgroundColor: AppColors.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              ingredient.nameRaw,
              style: AppTextStyles.body.copyWith(color: AppColors.textLight),
            ),
          ),
          if (ingredient.quantity != null)
            Text(
              _formatQuantity(ingredient),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}

String _formatQuantity(RecipeIngredient ing) {
  if (ing.quantity == null) return '';
  final qty = ing.quantity!;
  final qtyStr = qty == qty.truncateToDouble() ? qty.toInt().toString() : qty.toString();
  return ing.unit != null ? '$qtyStr ${ing.unit}' : qtyStr;
}
