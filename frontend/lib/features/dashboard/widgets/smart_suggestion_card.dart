import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_card.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/features/dashboard/providers/dashboard_provider.dart';

class SmartSuggestionCard extends ConsumerWidget {
  const SmartSuggestionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);

    return AppCard.dark(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Gold eyebrow label
          Text(
            'SMART SUGGESTION',
            style: AppTextStyles.label.copyWith(
              color: AppColors.accent,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 12),

          //Suggestion message built from model values
          Text(
            "You're ${state.smartSuggestionItemsAway} items away from making ${state.smartSuggestionRecipeCount} new recipes.",
            style: AppTextStyles.body.copyWith(
              color: AppColors.textDark,
            ),
          ),

          const SizedBox(height: 16),

          //Small icon to hint at action
          Icon(
            Icons.lightbulb_outline,
            color: AppColors.accent,
            size: 20,
          ),
        ],
      ),
    );
  }
}