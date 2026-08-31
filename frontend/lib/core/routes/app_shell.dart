import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../shared_widgets/Organisms/app_header.dart';
import '../shared_widgets/Organisms/app_navbar.dart';
import '../theme/app_colours.dart';
import 'app_routes.dart';

// Routes registered as children of the ShellRoute render as child here;
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        appBar: AppHeader(
          onCartTap: () => context.push(AppRoutes.shoppingLists),
        ),
        body: child,
        bottomNavigationBar: AppNavbar(
          currentRoute: location,
          onRouteSelected: (route) => context.go(route),
        ),
      ),
    );
  }
}