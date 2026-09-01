import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/shopping_lists/providers/shopping_list_provider.dart';
import '../shared_widgets/Organisms/app_header.dart';
import '../shared_widgets/Organisms/app_navbar.dart';
import '../shared_widgets/atoms/app_dropdown.dart';
import '../theme/app_colours.dart';
import 'app_routes.dart';

// Routes registered as children of the ShellRoute render as child here;
// The header config is chosen per route in _headerFor, so a new page needs only one arm there rather than its own scaffold on the page

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        appBar: _headerFor(context, ref, location),
        body: child,
        bottomNavigationBar: AppNavbar(
          currentRoute: location,
          onRouteSelected: (route) => context.go(route),
        ),
      ),
    );
  }

  PreferredSizeWidget? _headerFor(
    BuildContext context,
    WidgetRef ref,
    String location,
  ) {
    Future<void> logout() async {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) context.go(AppRoutes.login);
    }

    switch (location) {
      case AppRoutes.vault:
      case AppRoutes.shoppingLists:
      case AppRoutes.discovery:
      case AppRoutes.pantry:
      case AppRoutes.guidedDiscovery:
        return null;

      case AppRoutes.profile:
        return AppHeader(
          left: HeaderAction(icon: Icons.logout, onTap: logout),
          right: HeaderAction(
            icon: Icons.help_outline,
            onTap: () => context.push(AppRoutes.help),
          ),
        );

      default:
        return AppHeader(
          left: HeaderAction(
            icon: Icons.person_outline,
            onTap: () => context.go(AppRoutes.profile),
          ),
          right: HeaderAction(
            icon: Icons.shopping_cart_outlined,
            onTap: () => context.push(AppRoutes.shoppingLists),
            badgeCount: ref.watch(shoppingListCountProvider),
          ),
          titleItems: [
            AppDropdownItem(
              label: 'Profile',
              icon: Icons.person_outline,
              onTap: () => context.go(AppRoutes.profile),
            ),
            AppDropdownItem(
              label: 'Log out',
              icon: Icons.logout,
              destructive: true,
              onTap: logout,
            ),
          ],
        );
    }
  }
}
