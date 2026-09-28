import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';

class ShoppingBottomActionBar extends StatelessWidget {
  const ShoppingBottomActionBar({
    super.key,
    this.onAddTap,
  });

  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: Align(
        alignment: Alignment.centerRight,
        child: Semantics(
          button: true,
          enabled: onAddTap != null,
          label: 'Add shopping list item',
          child: Material(
            color:
                onAddTap == null ? AppColors.surfaceMuted : AppColors.primary,
            shape: const CircleBorder(),
            elevation: onAddTap == null ? 0 : 8,
            shadowColor: AppColors.primary.withValues(alpha: 0.28),
            child: InkWell(
              onTap: onAddTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 70,
                height: 70,
                child: Icon(
                  Icons.add,
                  color: onAddTap == null
                      ? AppColors.textMuted
                      : AppColors.textDark,
                  size: 34,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
