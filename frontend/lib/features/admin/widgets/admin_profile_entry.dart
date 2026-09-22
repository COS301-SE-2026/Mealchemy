import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../providers/admin_access_provider.dart';
import 'admin_access_message.dart';

class AdminProfileEntry extends ConsumerWidget {
  const AdminProfileEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(adminAccessStateProvider);

    //confirmed non-admin users and signed-out users have no Admin entry
    if (access == AdminAccess.forbidden ||
        access == AdminAccess.signInRequired) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: access == AdminAccess.allowed
          ? AppButton.outlined(
              label: 'Administration',
              leftIcon: Icons.admin_panel_settings_outlined,
              rightIcon: Icons.chevron_right,
              isFullWidth: true,
              onPressed: () {
                // Require a fresh backend check when entering the page.
                ref.invalidate(adminAccessProvider);
                context.push(AppRoutes.admin);
              },
            )
          : AdminAccessMessage(access: access),
    );
  }
}
