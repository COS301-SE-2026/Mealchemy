import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/atoms/app_button.dart';
import '../providers/admin_access_provider.dart';

class AdminProfileEntry extends ConsumerWidget {
  const AdminProfileEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(adminAccessStateProvider);

    if (access != AdminAccess.allowed) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: AppButton.outlined(
        label: 'Moderation',
        leftIcon: Icons.admin_panel_settings_outlined,
        rightIcon: Icons.chevron_right,
        isFullWidth: true,
        onPressed: () {
          ref.invalidate(adminAccessProvider);
          context.push(AppRoutes.admin);
        },
      ),
    );
  }
}
