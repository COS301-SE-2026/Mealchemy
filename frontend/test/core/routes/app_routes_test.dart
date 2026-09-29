import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/routes/app_routes.dart';

void main() {
  group('AppRoutes', () {
    test('all routes start with /', () {
      expect(AppRoutes.login.startsWith('/'), isTrue);
      expect(AppRoutes.dashboard.startsWith('/'), isTrue);
      expect(AppRoutes.pantry.startsWith('/'), isTrue);
      expect(AppRoutes.vault.startsWith('/'), isTrue);
      expect(AppRoutes.guidedDiscovery.startsWith('/'), isTrue);
    });

    test('all routes are unique', () {
      final routes = [
        AppRoutes.login,
        AppRoutes.dashboard,
        AppRoutes.pantry,
        AppRoutes.vault,
        AppRoutes.guidedDiscovery,
      ];
      expect(routes.toSet().length, routes.length);
    });

    test('builds a Cook Mode location without a step by default', () {
      expect(AppRoutes.cookModeLocation(7), '/recipe/7/cook');
    });

    test('builds a Cook Mode location for a specific step', () {
      expect(
        AppRoutes.cookModeLocation(7, stepIndex: 2),
        '/recipe/7/cook?step=2',
      );
    });
  });
}