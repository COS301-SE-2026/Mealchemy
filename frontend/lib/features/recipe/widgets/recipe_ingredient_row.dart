import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/recipe_ingredient.dart';

//a row in ingredientce list
class RecipeIngredientRow extends StatelessWidget {
  const RecipeIngredientRow({super.key, required this.ingredient});

  final RecipeIngredient ingredient;

  @override
  Widget build(BuildContext context) {
    final inPantry = ingredient.inPantry == true;
    final dotColor = inPantry ? AppColors.error : AppColors.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: dotColor),
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
          if (inPantry) ...[
            const SizedBox(width: 10),
            const _InPantryBadge(),
          ],
        ],
      ),
    );
  }
}

class _InPantryBadge extends StatelessWidget {
  const _InPantryBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'IN PANTRY',
        style: AppTextStyles.label.copyWith(
          color: AppColors.textDark,
          fontSize: 9,
          letterSpacing: 0.6,
        ),
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
