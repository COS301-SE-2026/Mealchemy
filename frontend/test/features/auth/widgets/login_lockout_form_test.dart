import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mealchemy/core/shared_widgets/atoms/app_button.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/auth/providers/login_lockout_provider.dart';
import 'package:mealchemy/features/auth/widgets/login_form.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('countdown disables only the locked email and expires',
      (tester) async {
    var now = DateTime.utc(2026, 9, 28);

    final container = ProviderContainer(
      overrides: [
        loginLockoutNowProvider.overrideWithValue(() => now),
      ],
    );

    container
        .read(loginLockoutProvider.notifier)
        .record('locked@example.com', 300);

    AppButton loginButton() {
      return tester.widget<AppButton>(
        find.ancestor(
          of: find.text('Log In'),
          matching: find.byType(AppButton),
        ),
      );
    }

    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: SingleChildScrollView(child: LoginForm()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'locked@example.com',
      );
      await tester.pump();

      expect(
        find.text('Too many failed attempts. Try again in 5:00.'),
        findsOneWidget,
      );
      expect(loginButton().onPressed, isNull);

      await tester.enterText(
        find.byType(TextField).first,
        'other@example.com',
      );
      await tester.pump();

      expect(find.textContaining('Too many failed attempts'), findsNothing);
      expect(loginButton().onPressed, isNotNull);

      await tester.enterText(
        find.byType(TextField).first,
        'locked@example.com',
      );
      await tester.pump();

      expect(loginButton().onPressed, isNull);

      now = now.add(const Duration(seconds: 241));
      container.read(loginLockoutProvider.notifier).refresh();
      await tester.pump();

      expect(
        find.text('Too many failed attempts. Try again in 0:59.'),
        findsOneWidget,
      );

      now = now.add(const Duration(seconds: 59));
      container.read(loginLockoutProvider.notifier).refresh();
      await tester.pump();

      expect(find.textContaining('Too many failed attempts'), findsNothing);
      expect(loginButton().onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      await tester.pump(Duration.zero);
    }
  });
}
