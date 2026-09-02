import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_card.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_icon_button.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/features/pantry/providers/pantry_provider.dart';

const _previewIcons = [
  Icons.cookie_outlined,
  Icons.egg_outlined,
  Icons.apple_outlined,
];

const _circleSize = 32.0;
const _overlapOffset = 22.0;

class DashboardPantryCard extends ConsumerWidget {
  const DashboardPantryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantryCount = ref.watch(pantryStateProvider).maybeWhen(
          data: (state) => state.summary.totalItems,
          orElse: () => 0,
        );
    final remaining = pantryCount - _previewIcons.length;

    return AppCard.light(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IN YOUR PANTRY',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textLight,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) =>
                    AppColors.brand.createShader(bounds),
                child: Text(
                  '$pantryCount',
                  style: AppTextStyles.display.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.surfaceWhite,
                  ),
                ),
              ),

              const SizedBox(width: 6),
              Text(
                'Ingredients',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),
              AppIconButton.primary(
                icon: Icons.add,
                onPressed: () => context.push(AppRoutes.addIngredient),
                size: 36,
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width:
                    _overlapOffset * (_previewIcons.length - 1) + _circleSize,
                height: _circleSize,
                child: Stack(
                  children: List.generate(_previewIcons.length, (index) {
                    return Positioned(
                      left: index * _overlapOffset,
                      child: Container(
                        width: _circleSize,
                        height: _circleSize,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryLight,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _previewIcons[index],
                          size: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              if (remaining > 0)
                Container(
                  width: _circleSize,
                  height: _circleSize,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryLight,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '+$remaining',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}