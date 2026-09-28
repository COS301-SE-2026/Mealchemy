import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/shared_widgets/atoms/app_badge.dart';
import '../../../core/shared_widgets/atoms/app_icon_button.dart';
import '../../../core/shared_widgets/Molecules/app_section_header.dart';
import '../../notifications/widgets/notification_bell.dart';
import '../../shopping_lists/providers/shopping_list_provider.dart';
import '../providers/incoming_vault_invitations_provider.dart';
import 'shared_vault_strip.dart';
import 'vault_switcher.dart';

class VaultHero extends ConsumerWidget {
  const VaultHero({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(shoppingListCountProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AppSectionHeader(
                  title: 'Vault',
                  titleStyle: AppTextStyles.heading1.copyWith(
                    color: AppColors.primary,
                    fontSize: 36,
                  ),
                ),
              ),
              const NotificationBell(color: AppColors.textLight),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AppIconButton.ghost(
                    icon: Icons.shopping_cart_outlined,
                    onPressed: () => context.push(AppRoutes.shoppingLists),
                    customColor: AppColors.textLight,
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: AppBadge(count: cartCount),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerLeft,
            child: VaultSwitcher(),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                ref.invalidate(incomingVaultInvitationsProvider);
                context.push(AppRoutes.incomingVaultInvitations);
              },
              icon: const Icon(Icons.mail_outline),
              label: const Text('Incoming invitations'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),

          //horizontal selector now uses the full header width
          const SharedVaultStrip(),
        ],
      ),
    );
  }
}
