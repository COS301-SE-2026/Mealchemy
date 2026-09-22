//maps each route string to its screen widget
import 'app_routes.dart';
import 'app_shell.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/admin/screens/admin_screen.dart';
import '../../features/admin/screens/admin_users_screen.dart';
import '../../features/admin/screens/admin_flag_detail_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/pantry/screens/pantry_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/vault/screens/vault_screen.dart';
import '../../features/pantry/screens/add_ingredient_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/recipe/screens/recipe_detail_screen.dart';
import '../../features/cook_mode/screens/cook_mode_screen.dart';
import '../../features/recipe/screens/add_recipe_screen.dart';
import '../../features/discovery/screens/discovery_screen.dart';
import '../../features/preference/screens/weights_screen.dart';

import '../../features/shopping_lists/screens/shopping_lists_screen.dart';
import '../../features/shopping_lists/screens/shopping_list_detail_screen.dart';
import '../../features/shopping_lists/screens/add_shopping_list_item_screen.dart';
import '../../features/guided_discovery/screens/guided_discovery_screen.dart';
import '../../features/help/screens/help_screen.dart';

import '../../features/recipe/models/recipe.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  // Sets the first screen shown when the app launches.
  // During development: change this to your screen (e.g. AppRoutes.pantry)
  // Before committing: ALWAYS reset this back to AppRoutes.login
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.addIngredient,
      pageBuilder: (context, state) =>
          _sheetPage(state.pageKey, const AddIngredientScreen()),
    ),
    GoRoute(
      path: AppRoutes.addRecipe,
      builder: (context, state) => const AddRecipeScreen(),
    ),
    GoRoute(
      path: AppRoutes.recipeEdit,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return AddRecipeScreen(editRecipeId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.editRecipe,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final recipe = state.extra as Recipe?;
        return AddRecipeScreen(editRecipeId: id, initialRecipe: recipe);
      },
    ),
    GoRoute(
      path: AppRoutes.cookMode,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final stepIndex = int.tryParse(
          state.uri.queryParameters['step'] ?? '',
        );
        return CookModeScreen(recipeId: id, initialStepIndex: stepIndex);
      },
    ),
    GoRoute(
      //note this has a parameter. to see screen: initialLocation: '/recipe/1',
      //only string literal wont work
      path: AppRoutes.recipeDetail,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return RecipeDetailScreen(recipeId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.shoppingListDetail,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ShoppingListDetailScreen(listId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.shoppingListAddItem,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AddShoppingListItemScreen(listId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.recommendationSettings,
      pageBuilder: (context, state) =>
          _sheetPage(state.pageKey, const WeightsScreen()),
    ),
    GoRoute(
      path: AppRoutes.help,
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: AppRoutes.admin,
      builder: (context, state) => const AdminScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminUsers,
      builder: (context, state) => const AdminUsersScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminFlagDetail,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');

        if (id == null || id <= 0) {
          return Scaffold(
            appBar: AppBar(title: const Text('Report')),
            body: const Center(child: Text('Invalid report ID.')),
          );
        }

        return AdminFlagDetailScreen(flaggedId: id);
      },
    ),

    // main destinations header + bottom nav supplied once by AppShell.
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          pageBuilder: (context, state) => NoTransitionPage(child: const DashboardScreen()),
        ),
        GoRoute(
          path: AppRoutes.vault,
          pageBuilder: (context, state) => NoTransitionPage(child: const VaultScreen()),
        ),
        GoRoute(
          path: AppRoutes.discovery,
          pageBuilder: (context, state) => NoTransitionPage(child: const DiscoveryScreen()),
        ),
        GoRoute(
          path: AppRoutes.pantry,
          pageBuilder: (context, state) => NoTransitionPage(child: const PantryScreen()),
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (context, state) => NoTransitionPage(child: const ProfileScreen()),
        ),
        GoRoute(
          path: AppRoutes.shoppingLists,
          pageBuilder: (context, state) => NoTransitionPage(child: const ShoppingListsScreen()),
        ),
        GoRoute(
          path: AppRoutes.guidedDiscovery,
          pageBuilder: (context, state) => NoTransitionPage(child: const GuidedDiscoveryScreen()),
        ),
      ],
    ),
  ],
);

// translucent slide up page keeps the previous screen painted underneath
// so a header BackdropFilter can blur it open with push, not go.
CustomTransitionPage<void> _sheetPage(LocalKey key, Widget child) {
  return CustomTransitionPage(
    key: key,
    opaque: false,
    barrierColor: Colors.transparent,
    child: child,
    transitionsBuilder: (context, animation, _, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      );
    },
  );
}
