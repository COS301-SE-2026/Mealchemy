import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/core/routes/app_shell.dart';
import 'package:mealchemy/core/shared_widgets/Organisms/app_header.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget host({required String initialLocation, int cartCount = 0}) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            for (final path in const [
              '/home',
              AppRoutes.vault,
              AppRoutes.shoppingLists,
              AppRoutes.discovery,
              AppRoutes.pantry,
              AppRoutes.guidedDiscovery,
              AppRoutes.profile,
            ])
              GoRoute(
                path: path,
                builder: (_, __) => const Text('page'),
              ),
          ],
        ),
        GoRoute(
          path: AppRoutes.help,
          builder: (_, __) => const Text('help'),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, __) => const Text('login'),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        shoppingListCountProvider.overrideWithValue(cartCount),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('AppShell header routing', () {
    testWidgets('shows no header on the vault route', (tester) async {
      await tester.pumpWidget(host(initialLocation: AppRoutes.vault));
      await tester.pumpAndSettle();

      expect(find.byType(AppHeader), findsNothing);
    });

    testWidgets('shows no header on the pantry route', (tester) async {
      await tester.pumpWidget(host(initialLocation: AppRoutes.pantry));
      await tester.pumpAndSettle();

      expect(find.byType(AppHeader), findsNothing);
    });

    testWidgets('shows the profile header with logout and help actions',
        (tester) async {
      await tester.pumpWidget(host(initialLocation: AppRoutes.profile));
      await tester.pumpAndSettle();

      expect(find.byType(AppHeader), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
    });

    testWidgets('shows the default header with account and cart actions',
        (tester) async {
      await tester.pumpWidget(host(initialLocation: '/home'));
      await tester.pumpAndSettle();

      expect(find.byType(AppHeader), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });
  });

  group('AppShell cart badge', () {
    testWidgets('reflects the shopping list count on the default header',
        (tester) async {
      await tester.pumpWidget(host(initialLocation: '/home', cartCount: 3));
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows no badge count when there are no lists', (tester) async {
      await tester.pumpWidget(host(initialLocation: '/home', cartCount: 0));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsNothing);
    });
  });
}