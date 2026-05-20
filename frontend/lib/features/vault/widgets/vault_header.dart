import 'package:flutter/material.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

class VaultHeader extends StatelessWidget {
  const VaultHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MY VAULT',
          style: AppTextStyles.label.copyWith(
            color: AppColors.primary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Private Vault',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your personal recipe collection.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}