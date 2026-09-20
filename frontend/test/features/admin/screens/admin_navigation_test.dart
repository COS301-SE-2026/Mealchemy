import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/routes/app_router.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/features/admin/providers/admin_access_provider.dart';
import 'package:mealchemy/features/admin/screens/admin_screen.dart';
import 'package:mealchemy/features/admin/widgets/admin_profile_entry.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  for (final access in AdminAccess.values) {
    testWidgets('Profile entry handles ${access.name}', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminAccessProvider.overrideWith((ref) async => access),
          ],
          child: const MaterialApp(
            home: Scaffold(body: AdminProfileEntry()),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text('Administration'),
        access == AdminAccess.allowed ? findsOneWidget : findsNothing,
      );

      if (access == AdminAccess.forbidden ||
          access == AdminAccess.signInRequired) {
        expect(find.byType(Text), findsNothing);
      }
    });
  }

  for (final access in AdminAccess.values) {
    testWidgets('direct Admin route handles ${access.name}', (tester) async {
      final router = GoRouter(
        initialLocation: AppRoutes.admin,
        // Uses the actual application route definitions.
        routes: appRouter.configuration.routes,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminAccessProvider.overrideWith((ref) async => access),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(AdminScreen), findsOneWidget);
      expect(
        find.text('COMMUNITY MANAGEMENT'),
        access == AdminAccess.allowed ? findsOneWidget : findsNothing,
      );
    });
  }

  testWidgets('Profile navigation checks access again before showing content',
      (tester) async {
    var checks = 0;
    final pending = Completer<AdminAccess>();

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: AdminProfileEntry()),
        ),
        GoRoute(
          path: AppRoutes.admin,
          builder: (_, __) => const AdminScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminAccessProvider.overrideWith((ref) async {
            checks++;
            if (checks == 1) return AdminAccess.allowed;
            return pending.future;
          }),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Administration'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(checks, 2);

    final adminScreen = find.byType(AdminScreen);
    expect(adminScreen, findsOneWidget);

    expect(
      find.descendant(
        of: adminScreen,
        matching: find.text('COMMUNITY MANAGEMENT'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: adminScreen,
        matching: find.text('Checking admin access…'),
      ),
      findsOneWidget,
    );

    pending.complete(AdminAccess.forbidden);
    await tester.pumpAndSettle();

    expect(find.text('COMMUNITY MANAGEMENT'), findsNothing);
    expect(
      find.text('Your account does not have administrator access.'),
      findsOneWidget,
    );
  });

  testWidgets('Retry recovers from an unavailable access check',
      (tester) async {
    var checks = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminAccessProvider.overrideWith((ref) async {
            checks++;
            return checks == 1 ? AdminAccess.unavailable : AdminAccess.allowed;
          }),
        ],
        child: const MaterialApp(home: AdminScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('COMMUNITY MANAGEMENT'), findsNothing);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(checks, 2);
    expect(find.text('COMMUNITY MANAGEMENT'), findsOneWidget);
  });
}
