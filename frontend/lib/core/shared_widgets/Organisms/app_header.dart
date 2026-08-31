import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../atoms/app_dropdown.dart';
import '../atoms/app_icon_button.dart';
import '../../theme/app_colours.dart';
import '../../theme/app_typography.dart';

// a configurable left/right header slot an icon, its tap action, and an
// optional count badge 
class HeaderAction {
  const HeaderAction({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;
}

// Shared top bar, added per screen like AppNavbar.
// the layout is driven by data. Pass (lef / right) actions (or leave them null for an empty slot), and titleItems to make the
// centred Mealchemy title a dropdown 
class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.left,
    this.right,
    this.titleItems,
  });

  final HeaderAction? left;
  final HeaderAction? right;
  final List<AppDropdownItem>? titleItems;

  bool get _titleIsDropdown => titleItems != null && titleItems!.isNotEmpty;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              _title(),
              Row(
                children: [
                  _slot(left),
                  const Spacer(),
                  _slot(right),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title() {
    const title = 'Mealchemy';

    if (!_titleIsDropdown) {
      return Text(
        title,
        style: AppTextStyles.title.copyWith(color: AppColors.primary),
      );
    }

    return AppDropdown(
      trigger: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyles.title.copyWith(color: AppColors.primary),
          ),
          const SizedBox(width: 2),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 22,
            color: AppColors.primary,
          ),
        ],
      ),
      items: titleItems!,
    );
  }

  Widget _slot(HeaderAction? action) {
    if (action == null) return const SizedBox(width: 44);
    return _ActionButton(action: action);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});

  final HeaderAction action;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppIconButton.ghost(
          icon: action.icon,
          onPressed: action.onTap,
          customColor: AppColors.primary,
          size: 44,
        ),
        if (action.badgeCount > 0)
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
                action.badgeCount > 99 ? '99+' : '${action.badgeCount}',
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