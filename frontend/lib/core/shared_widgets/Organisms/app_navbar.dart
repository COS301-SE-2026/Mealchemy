import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colours.dart';
import '../../theme/app_typography.dart';

//bottom nav
class AppNavItem {
  const AppNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

//shared bottom nav for the app screens
class AppNavbar extends StatelessWidget {
  const AppNavbar({
    super.key,
    required this.currentRoute,
    required this.onRouteSelected,
    this.items = defaultItems,
  });

  final String currentRoute;
  final ValueChanged<String> onRouteSelected;
  final List<AppNavItem> items;

  static const List<AppNavItem> defaultItems = [
    AppNavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      route: AppRoutes.dashboard,
    ),
     AppNavItem(
      label: 'Vault',
      icon: Icons.bookmark_border,
      route: AppRoutes.vault,
    ),
    AppNavItem(
      label: 'Discover',
      icon: Icons.explore_outlined,
      route: AppRoutes.discovery,
    ),
    AppNavItem(
      label: 'Pantry',
      icon: Icons.kitchen_outlined,
      route: AppRoutes.pantry,
    ),
    AppNavItem(
      label: 'Profile',
        icon: Icons.person_outline,
      route: AppRoutes.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          border: Border(
            top: BorderSide(
              color: AppColors.divider.withValues(alpha: 0.7),
            ),
          ),
        ),
        child: Row(
          children: items.map((item) {
            final selected = item.route == currentRoute;

            return Expanded(
              child: _NavbarButton(
                item: item,
                selected: selected,
                onTap: () => onRouteSelected(item.route),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavbarButton extends StatelessWidget {
  const _NavbarButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: color, size: 22),
            ),
            const SizedBox(height: 3),
            Text(
              item.label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(
                color: color,
                fontSize: 9,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}