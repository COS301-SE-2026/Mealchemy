import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/admin_access_provider.dart';

class AdminAccessMessage extends ConsumerWidget {
  const AdminAccessMessage({
    super.key,
    required this.access,
  });

  final AdminAccess access;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (access == AdminAccess.allowed) {
      return const SizedBox.shrink();
    }

    final message = switch (access) {
      AdminAccess.checking => 'Checking admin access…',
      AdminAccess.forbidden =>
        'Your account does not have administrator access.',
      AdminAccess.signInRequired =>
        'Sign in again to verify administrator access.',
      AdminAccess.offline =>
        'Connect to the internet to verify administrator access.',
      AdminAccess.unavailable =>
        'We could not verify administrator access. Please try again.',
      AdminAccess.allowed => '',
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (access == AdminAccess.checking) ...[
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          message,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        if (access == AdminAccess.signInRequired) ...[
          const SizedBox(height: 12),
          AppButton(
            label: 'Sign in',
            onPressed: () => context.go(AppRoutes.login),
          ),
        ],
        if (access == AdminAccess.unavailable ||
            access == AdminAccess.forbidden) ...[
          const SizedBox(height: 12),
          AppButton.outlined(
            label: 'Retry',
            onPressed: () => ref.invalidate(adminAccessProvider),
          ),
        ],
      ],
    );
  }
}
