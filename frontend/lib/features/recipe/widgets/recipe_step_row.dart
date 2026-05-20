import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../models/recipe_step.dart';

//one numbered step in the preparation list
class RecipeStepRow extends StatelessWidget {
  const RecipeStepRow({super.key, required this.step});

  final RecipeStep step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              step.stepNr.toString().padLeft(2, '0'),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.accentMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              step.content,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textLight,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
