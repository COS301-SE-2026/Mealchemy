import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/theme/app_typography.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_badge.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_icon_button.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_section_header.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';
import 'vault_switcher.dart';
import 'shared_vault_strip.dart';

class VaultHero extends ConsumerWidget {
  const VaultHero({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(shoppingListCountProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionHeader(
                  title: 'Vault',
                  titleStyle: AppTextStyles.heading1.copyWith(
                    color: AppColors.primary,
                    fontSize: 36,
                  ),
                ),
                const SizedBox(height: 8),
                const VaultSwitcher(),
                const SharedVaultStrip(),
              ],
            ),
          ),
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
    );
  }
}