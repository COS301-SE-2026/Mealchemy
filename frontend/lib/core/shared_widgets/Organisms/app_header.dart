import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/shopping_lists/providers/shopping_list_provider.dart';
import '../../routes/app_routes.dart';
import '../atoms/app_dropdown.dart';
import '../atoms/app_icon_button.dart';
import '../../theme/app_colours.dart';
import '../../theme/app_typography.dart';

//  Shared top bar added per screen.
// Left avatar placeholder for now  profile image or icon goes here later.
// Centre Mealchemy title opening the account dropdown profile, log ou.
// Right  cart icon wth a shopping list count badge.
class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.onAvatarTap,
    required this.onCartTap,
  });

  final VoidCallback? onAvatarTap;
  final VoidCallback onCartTap;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(shoppingListCountProvider);

    //Colour sits outside the  SafeArea so it fills the status bar
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.7),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          //the title  will constatly stay in the middle of the header
          child: Stack(
            alignment: Alignment.center,
            children: [
              AppDropdown(
                trigger: const _TitleTrigger(),
                items: [
                  AppDropdownItem(
                    label: 'Profile',
                    icon: Icons.person_outline,
                    onTap: () => context.go(AppRoutes.profile),
                  ),
                  AppDropdownItem(
                    label: 'Log out',
                    icon: Icons.logout,
                    destructive: true,
                    onTap: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) context.go(AppRoutes.login);
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  _Avatar(onTap: onAvatarTap),
                  const Spacer(),
                  _CartButton(count: count, onTap: onCartTap),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleTrigger extends StatelessWidget {
  const _TitleTrigger();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Mealchemy',
          style: AppTextStyles.title.copyWith(color: AppColors.primary),
        ),
        const SizedBox(width: 2),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 22,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.tertiaryMuted.withValues(alpha: 0.35),
          border: Border.all(
            color: AppColors.inputBorder,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppIconButton.ghost(
          icon: Icons.shopping_cart_outlined,
          onPressed: onTap,
          customColor: AppColors.primary,
          size: 44,
        ),
        if (count > 0)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 18),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.bgLight, width: 1.5),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textLight,
                  fontSize: 9,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
