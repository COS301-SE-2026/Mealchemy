import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';

class HelpHeader extends StatelessWidget {
  const HelpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textLight,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              'Help & Support',
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ),

          const SizedBox(width: 48),
        ],
      ),
    );
  }
}