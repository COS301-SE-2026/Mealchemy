import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/routes/app_router.dart';
import 'package:mealchemy/core/routes/app_routes.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> go(WidgetTester tester, String location) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: appRouter)),
    );
    await tester.pump();
    appRouter.go(location);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  tearDown(() => appRouter.go(AppRoutes.login));

  group('appRouter', () {
    testWidgets('starts on login', (tester) async {
      await go(tester, AppRoutes.login);
      expect(tester.takeException(), isNull);
    });

    testWidgets('builds the simple routes', (tester) async {
      for (final path in [
        AppRoutes.signup,
        AppRoutes.addRecipe,
        AppRoutes.help,
        AppRoutes.admin,
        AppRoutes.adminUsers,
        AppRoutes.incomingVaultInvitations,
      ]) {
        await go(tester, path);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('builds the shell routes', (tester) async {
      for (final path in [
        AppRoutes.dashboard,
        AppRoutes.vault,
        AppRoutes.discovery,
        AppRoutes.pantry,
        AppRoutes.profile,
        AppRoutes.shoppingLists,
        AppRoutes.guidedDiscovery,
      ]) {
        await go(tester, path);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('builds the sheet routes', (tester) async {
      await go(tester, AppRoutes.addIngredient);
      await go(tester, AppRoutes.recommendationSettings);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a valid vault id reaches the members screen', (tester) async {
      await go(tester, '/vault/12/members');
      expect(find.text('Invalid vault ID.'), findsNothing);
    });

    testWidgets('a bad vault id shows the members guard', (tester) async {
      await go(tester, '/vault/abc/members');
      expect(find.text('Invalid vault ID.'), findsOneWidget);
    });

    testWidgets('a zero vault id shows the members guard', (tester) async {
      await go(tester, '/vault/0/members');
      expect(find.text('Invalid vault ID.'), findsOneWidget);
    });

    testWidgets('a bad vault id shows the invitations guard', (tester) async {
      await go(tester, '/vault/abc/invitations');
      expect(find.text('Invalid vault ID.'), findsOneWidget);
    });

    testWidgets('a bad flag id shows the report guard', (tester) async {
      await go(tester, '/admin/flags/abc');
      expect(find.text('Invalid report ID.'), findsOneWidget);
    });

    testWidgets('a zero flag id shows the report guard', (tester) async {
      await go(tester, '/admin/flags/0');
      expect(find.text('Invalid report ID.'), findsOneWidget);
    });
  });
}