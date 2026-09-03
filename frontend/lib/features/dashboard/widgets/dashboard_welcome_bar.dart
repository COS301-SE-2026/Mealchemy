import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/features/profile/providers/profile_provider.dart';

class DashboardWelcomeBar extends ConsumerWidget {
  const DashboardWelcomeBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(profileProvider).maybeWhen(
          data: (state) {
            final displayName = state.draft.displayName.trim();
            return displayName.isEmpty ? 'Chef' : displayName;
          },
          orElse: () => 'Chef',
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'What are we cooking today, ',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textLight,
            ),
          ),
          Text(
            '$name?',
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}