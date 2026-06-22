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
    final summaryAsync = ref.watch(pantrySummaryProvider);

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

          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              summaryAsync.when(
                data: (summary) => Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${summary.totalItems}',
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Ingredients',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                loading: () => Text(
                  '--',
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                error: (_, __) => Text(
                  '--',
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),

              const Spacer(),

              AppIconButton.primary(
                icon: Icons.add,
                onPressed: () => context.push(AppRoutes.addIngredient),
                size: 40,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Overlapping icon circles with remaining count
          summaryAsync.when(
            data: (summary) {
              final remaining = summary.totalItems - _previewIcons.length;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: _overlapOffset * (_previewIcons.length - 1) + _circleSize,
                    height: _circleSize,
                    child: Stack(
                      children: List.generate(_previewIcons.length, (index) {
                        return Positioned(
                          left: index * _overlapOffset,
                          child: Container(
                            width: _circleSize,
                            height: _circleSize,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
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
                    Text(
                      '+$remaining',
                      style: AppTextStyles.bodyBold.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              );
            },
            loading: () => const SizedBox(height: _circleSize),
            error: (_, __) => const SizedBox(height: _circleSize),
          ),
        ],
      ),
    );
  }
}