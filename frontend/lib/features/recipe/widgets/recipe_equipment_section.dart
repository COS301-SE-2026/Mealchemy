import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/equipment.dart';

class RecipeEquipmentSection extends StatelessWidget {
  const RecipeEquipmentSection({super.key, required this.equipment});

  final List<Equipment> equipment;

  static const _icons = {
    'OVEN': Icons.countertops_outlined,
    'STOVETOP': Icons.local_fire_department_outlined,
    'MICROWAVE': Icons.microwave_outlined,
    'AIR_FRYER': Icons.air,
    'BLENDER': Icons.blender_outlined,
    'FOOD_PROCESSOR': Icons.blender_outlined,
    'SLOW_COOKER': Icons.soup_kitchen_outlined,
    'RICE_COOKER': Icons.rice_bowl_outlined,
    'TOASTER': Icons.breakfast_dining_outlined,
    'GRILL': Icons.outdoor_grill_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final e in equipment)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const CircleAvatar(radius: 4, backgroundColor: AppColors.accent),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    e.label,
                    style:
                        AppTextStyles.body.copyWith(color: AppColors.textLight),
                  ),
                ),
                Icon(
                  _icons[e.value] ?? Icons.restaurant_outlined,
                  color: AppColors.textMuted,
                  size: 18,
                ),
              ],
            ),
          ),
      ],
    );
  }
}