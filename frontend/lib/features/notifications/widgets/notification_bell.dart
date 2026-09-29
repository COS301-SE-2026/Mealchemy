import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/shared_widgets/atoms/app_badge.dart';
import '../../../core/shared_widgets/atoms/app_icon_button.dart';
import '../../../core/theme/app_colours.dart';
import '../../vault/providers/shared_vault_access_provider.dart';
import '../providers/notification_inbox_provider.dart';

class NotificationBell extends ConsumerWidget {
  const NotificationBell({
    super.key,
    this.color = AppColors.primary,
  });

  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(vaultSessionProvider);

    if (session.restoring ||
        !session.hasValidCredential ||
        session.userId == null ||
        session.token == null) {
      return const SizedBox.shrink();
    }

    final count = ref.watch(
      notificationInboxProvider.select((state) => state.unreadCount),
    );

    return Tooltip(
      message: 'Notifications',
      child: Semantics(
        label: count == null ? 'Notifications' : 'Notifications, $count unread',
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AppIconButton.ghost(
              icon: Icons.notifications_none_outlined,
              customColor: color,
              onPressed: () => context.push(AppRoutes.notifications),
            ),
            if (count != null && count > 0)
              Positioned(
                top: 2,
                right: 2,
                child: IgnorePointer(
                  child: AppBadge(count: count),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
