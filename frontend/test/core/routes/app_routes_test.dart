import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/routes/app_routes.dart';

void main() {
  group('AppRoutes', () {
    test('all routes start with /', () {
      expect(AppRoutes.login.startsWith('/'), isTrue);
      expect(AppRoutes.dashboard.startsWith('/'), isTrue);
      expect(AppRoutes.pantry.startsWith('/'), isTrue);
      expect(AppRoutes.vault.startsWith('/'), isTrue);
      expect(AppRoutes.preference.startsWith('/'), isTrue);
    });

    test('all routes are unique', () {
      final routes = [
        AppRoutes.login,
        AppRoutes.dashboard,
        AppRoutes.pantry,
        AppRoutes.vault,
        AppRoutes.preference,
      ];
      expect(routes.toSet().length, routes.length);
    });
  });
}