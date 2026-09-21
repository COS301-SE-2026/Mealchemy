import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/admin_access_provider.dart';
import '../widgets/admin_access_message.dart';
import '../widgets/admin_queue_section.dart';
import '../providers/admin_queue_provider.dart';
import '../../../core/shared_widgets/Molecules/app_refresh.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(adminAccessStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.profile);
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh admin access',
            icon: const Icon(Icons.refresh),
            onPressed:
                access == AdminAccess.checking || access == AdminAccess.offline
                    ? null
                    : () => ref.invalidate(adminAccessProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: AppRefresh(
          onRefresh: () async {
            if (access != AdminAccess.allowed) {
              ref.invalidate(adminAccessProvider);
              return;
            }

            final status = ref.read(adminQueueStatusProvider);
            try {
              ref.invalidate(adminQueueProvider(status));
              await ref.read(adminQueueProvider(status).future);
            } catch (_) {
              //queue renders the resulting error state
            }
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              if (access == AdminAccess.allowed)
                const _AdminContent()
              else
                AdminAccessMessage(access: access),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminContent extends StatelessWidget {
  const _AdminContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMMUNITY MANAGEMENT',
          style: AppTextStyles.label.copyWith(
            color: AppColors.primary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Administration',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Review community reports and manage administrator access.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 20),
        AppButton.outlined(
          label: 'Manage admins',
          leftIcon: Icons.manage_accounts_outlined,
          rightIcon: Icons.chevron_right,
          isFullWidth: true,
          onPressed: () => context.push(AppRoutes.adminUsers),
        ),
        const SizedBox(height: 28),
        const AdminQueueSection(),
      ],
    );
  }
}
