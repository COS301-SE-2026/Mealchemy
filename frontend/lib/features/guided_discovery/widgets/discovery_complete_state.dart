import 'package:flutter/material.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

//displays completion screen shown after user has reviewed all recommended recipes
class DiscoveryCompleteState extends StatelessWidget {
  const DiscoveryCompleteState({
    super.key,
    //recipe counts
    required this.likedCount,
    required this.dislikedCount,
    required this.onReset,
  });

  final int likedCount;
  final int dislikedCount;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome,
              color: AppColors.accent,
              size: 46,
            ),
            const SizedBox(height: 14),
            Text(
              'Discovery complete',
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            //summary
            Text(
              'You liked $likedCount recipes and skipped $dislikedCount. Your mock recommendations are ready.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.tertiaryMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: onReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textDark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
              ),
              child: const Text('Start Again'),
            ),
          ],
        ),
      ),
    );
  }
}