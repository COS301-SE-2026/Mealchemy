//maps each route string to its screen widget
import 'app_routes.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/pantry/screens/pantry_screen.dart';
import '../../features/preference/screens/preference_screen.dart';
import '../../features/vault/screens/vault_screen.dart';


final appRouter = GoRouter(
  initialLocation: AppRoutes.login, // Sets the first screen shown when the app launches. 
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
  ],
);
