import 'package:flutter/material.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import '../models/meal_plan_entry.dart';
import '../models/meal_slot.dart';

Future<void> showMealEntrySheet(
  BuildContext context, {
  required int vaultId,
  MealPlanEntry? entry,
  MealSlot? slot,
}) {
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppColors.surfaceWhite,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: _MealEntrySheet(vaultId: vaultId, entry: entry, slot: slot),
    ),
  );
}

class _MealEntrySheet extends StatelessWidget {
  const _MealEntrySheet({required this.vaultId, this.entry, this.slot});

  final int vaultId;
  final MealPlanEntry? entry;
  final MealSlot? slot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry == null ? 'Add Meal' : 'Edit Meal',
            style: AppTextStyles.heading2.copyWith(color: AppColors.primary, fontSize: 22),
          ),
        ],
      ),
    );
  }
}