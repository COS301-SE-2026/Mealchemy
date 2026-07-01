import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/shopping_list_item.dart';

//single ingredient/item row on a shopping list detail page
class ShoppingItemRow extends StatelessWidget {
  const ShoppingItemRow({
    super.key,
    required this.item,
    required this.onChanged,
  });

  final ShoppingListItem item;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: item.checked,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              checkColor: AppColors.textDark,
              side: const BorderSide(
                color: AppColors.primary,
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: item.checked
                    ? AppColors.tertiaryMuted
                    : AppColors.textLight,
                fontSize: 16,
                decoration:
                    item.checked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            item.quantity,
            style: AppTextStyles.body.copyWith(
              color: AppColors.tertiaryMuted,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}