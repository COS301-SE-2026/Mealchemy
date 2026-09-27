import 'package:flutter/material.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_icon_button.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/features/recipe/widgets/recipe_network_image.dart';
import '../models/meal_plan_entry.dart';
import '../models/meal_slot.dart';

class MealPlanEntryCard extends StatelessWidget {
  const MealPlanEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.onEdit,
  });

  final MealPlanEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final time = MealPlanEntry.formatTime(entry.mealTime);
    final subtitle = entry.note == null || entry.note!.isEmpty
        ? time
        : '$time  ·  ${entry.note}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 76,
                height: 76,
                child: RecipeNetworkImage(
                  photoUrl: entry.recipe?.photoUrl,
                  placeholder: Container(
                    decoration: const BoxDecoration(gradient: AppColors.brand),
                    child: const Icon(
                      Icons.soup_kitchen_outlined,
                      color: AppColors.textDark,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (entry.source == MealEntrySource.recommended) ...[
                        const Icon(Icons.auto_awesome, size: 12, color: AppColors.accentMuted),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        entry.mealSlot.label.toUpperCase(),
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.accentMuted,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.displayTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.heading2.copyWith(
                      fontSize: 17,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (onEdit != null)
              AppIconButton.ghost(
                icon: Icons.edit_outlined,
                onPressed: onEdit,
                customColor: AppColors.primaryLight,
                size: 36,
              ),
          ],
        ),
      ),
    );
  }
}