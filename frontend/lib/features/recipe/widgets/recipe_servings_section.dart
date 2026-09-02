import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared_widgets/atoms/app_card.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/recipe_provider.dart';

class RecipeServingsSection extends ConsumerWidget {
  const RecipeServingsSection({
    super.key,
    required this.recipeId,
    required this.baseServings,
  });

  final int recipeId;
  final int baseServings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stored = ref.watch(servingsProvider(recipeId));
    final servings = stored == 0 ? baseServings : stored;
    final isChanged = servings != baseServings;

    void setServings(int value) {
      if (value < 1) return;
      ref.read(servingsProvider(recipeId).notifier).state = value;
    }

    return AppCard.outlined(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        children: [
          const Icon(Icons.people_outline,
              color: AppColors.accentMuted, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$servings',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                servings == 1 ? 'Serving' : 'Servings',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const Spacer(),
          if (isChanged)
            TextButton(
              onPressed: () => setServings(baseServings),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Reset',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          _StepperButton(
            icon: Icons.remove,
            onTap: servings > 1 ? () => setServings(servings - 1) : null,
          ),
          const SizedBox(width: 10),
          _StepperButton(
            icon: Icons.add,
            onTap: () => setServings(servings + 1),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? AppColors.primary : AppColors.surfaceMuted,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? AppColors.textDark : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}