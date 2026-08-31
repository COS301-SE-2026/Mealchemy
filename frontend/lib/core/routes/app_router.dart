//maps each route string to its screen widget
import 'app_routes.dart';
import 'app_shell.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/pantry/screens/pantry_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/vault/screens/vault_screen.dart';
import '../../features/pantry/screens/add_ingredient_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/recipe/screens/recipe_detail_screen.dart';
import '../../features/recipe/screens/add_recipe_screen.dart';
import '../../features/discovery/screens/discovery_screen.dart';

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
      //translucent overlay: opaque false keeps the previous screen
      //visible so the header can blur it. open with push, not go

      path: AppRoutes.addIngredient,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        opaque: false,
        barrierColor: Colors.transparent,
        child: const AddIngredientScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
      ),
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
      //note this has a parameter. to see screen: initialLocation: '/recipe/1',
      //only string literal wont work
      path: AppRoutes.recipeDetail,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return RecipeDetailScreen(recipeId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.shoppingLists,
      builder: (context, state) => const ShoppingListsScreen(),
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
      path: AppRoutes.guidedDiscovery,
      builder: (context, state) => const GuidedDiscoveryScreen(),
    ),
    GoRoute(
      path: AppRoutes.help,
      builder: (context, state) => const HelpScreen(),
    ),

    // main destinations header + bottom nav supplied once by AppShell.
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.vault,
          builder: (context, state) => const VaultScreen(),
        ),
        GoRoute(
          path: AppRoutes.discovery,
          builder: (context, state) => const DiscoveryScreen(),
        ),
        GoRoute(
          path: AppRoutes.pantry,
          builder: (context, state) => const PantryScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);