import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/shared_widgets/Organisms/app_navbar.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/features/dashboard/providers/dashboard_provider.dart';
import 'package:mealchemy/features/dashboard/widgets/dashboard_welcome_bar.dart';
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
 
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    //Load dashboard data when screen first mounts
    Future.microtask(
      () => ref.read(dashboardProvider.notifier).loadDashboard(),
    );
  }

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// app will be added later
 
              const SizedBox(height: 16),
 
              const DashboardWelcomeBar(),
 
              const SizedBox(height: 24),
 
              //pantry summary + smart suggestion cards
              /// recommended for You section
              //trending Recipes section
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppNavbar(
        currentRoute: AppRoutes.dashboard,
        onRouteSelected: (route) => context.go(route),
      ),
    );
  }
}