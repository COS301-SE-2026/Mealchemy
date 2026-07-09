//maps each route string to its screen widget
import 'app_routes.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/pantry/screens/pantry_screen.dart';
import '../../features/preference/screens/preference_screen.dart';
import '../../features/vault/screens/vault_screen.dart';
import '../../features/pantry/screens/add_ingredient_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/recipe/screens/recipe_detail_screen.dart';
import '../../features/recipe/screens/add_recipe_screen.dart';
import '../../features/shopping_lists/screens/shopping_lists_screen.dart';
import '../../features/shopping_lists/screens/shopping_list_detail_screen.dart';
import '../../features/guided_discovery/screens/guided_discovery_screen.dart';

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
      path: AppRoutes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.guidedDiscovery,
      builder: (context, state) => const GuidedDiscoveryScreen(),
    ),
    GoRoute(
      path: AppRoutes.pantry,
      builder: (context, state) => const PantryScreen(),
    ),
    GoRoute(
      path: AppRoutes.preference,
      builder: (context, state) => const PreferenceScreen(),
    ),
    GoRoute(
      path: AppRoutes.vault,
      builder: (context, state) => const VaultScreen(),
    ),
    GoRoute(
      path: AppRoutes.addIngredient,
      builder: (context, state) => const AddIngredientScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.addRecipe,
      builder: (context, state) => const AddRecipeScreen(),
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
      //note this has a parameter. to see screen: initialLocation: '/recipe/1',
      //only string literal wont work
      path: AppRoutes.recipeDetail,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return RecipeDetailScreen(recipeId: id);
      },
    ),
  ],
);
