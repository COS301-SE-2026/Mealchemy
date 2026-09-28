import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_refresh.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import 'package:mealchemy/features/cook_mode/providers/cook_timer_provider.dart';
import 'package:mealchemy/features/dashboard/providers/dashboard_provider.dart';
import 'package:mealchemy/features/dashboard/widgets/dashboard_welcome_bar.dart';
import 'package:mealchemy/features/dashboard/widgets/continue_cooking_row.dart';
import 'package:mealchemy/features/dashboard/widgets/dashboard_active_timers.dart';
import 'package:mealchemy/features/dashboard/widgets/dashboard_cards_row.dart';
import 'package:mealchemy/features/dashboard/widgets/recommended_recipes_section.dart';
import 'package:mealchemy/features/meal_plan/providers/meal_plan_provider.dart';
import 'package:mealchemy/features/meal_plan/widgets/meal_plan_section.dart';
import 'package:mealchemy/features/pantry/providers/pantry_provider.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';
import 'package:mealchemy/features/vault/providers/vault_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    //Load dashboard data and warm the pantry and shopping-list providers
    Future.microtask(() {
      ref.read(dashboardProvider.notifier).loadDashboard();
      ref.read(pantryStateProvider);
      ref.read(shoppingListsProvider);
    });
  }

  Future<void> _refresh() async {
    final vaultId = ref.read(privateVaultProvider)?.vaultId;
    await Future.wait([
      ref.read(dashboardProvider.notifier).loadDashboard(),
      if (vaultId != null) ref.read(mealPlanProvider(vaultId).notifier).load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(activeIdentityProvider);
    final timerState = ref.watch(cookTimerControllerProvider(userId));
    final privateVault = ref.watch(privateVaultProvider);

    return AppRefresh(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const DashboardWelcomeBar(),
            const ContinueCookingRow(),
            DashboardActiveTimers(
              timers: timerState.activeTimers,
              now: timerState.now,
              onTimerTap: (timer) => context.push(
                AppRoutes.cookModeLocation(
                  timer.recipeId,
                  stepIndex: timer.stepIndex,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const DashboardCardsRow(),
            const SizedBox(height: 28),
            const RecommendedRecipesSection(),
            const SizedBox(height: 28),
            if (privateVault != null) ...[
              MealPlanSection(
                vaultId: privateVault.vaultId,
                allowVaultSwitch: true,
              ),
              const SizedBox(height: 28),
            ],
          ],
        ),
      ),
    );
  }
}