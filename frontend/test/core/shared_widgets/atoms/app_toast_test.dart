import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/theme/app_colours.dart';
import 'package:mealchemy/core/shared_widgets/atoms/app_toast.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pump(WidgetTester tester, Widget toast) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: toast),
        ),
      ),
    );
  }

  Finder accentBar() => find.byWidgetPredicate((w) {
        if (w is! Container) return false;
        final c = w.color;
        final constraints = w.constraints;
        return c == AppColors.error && constraints?.maxWidth == 4;
      });

  group('AppToast.short', () {
    testWidgets('renders the message', (tester) async {
      await pump(tester, const AppToast.short(message: 'Saved to My Recipes'));
      expect(find.text('Saved to My Recipes'), findsOneWidget);
    });

    testWidgets('shows the first  icon when provided', (tester) async {
      await pump(
        tester,
        const AppToast.short(message: 'Saved', icon: Icons.bookmark_added),
      );
      expect(find.byIcon(Icons.bookmark_added), findsOneWidget);
    });

    testWidgets('removes  the icon when none  is given', (tester) async {
      await pump(tester, const AppToast.short(message: 'Saved'));
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('no accent bar for a success toast  ', (tester) async {
      await pump(
        tester,
        const AppToast.short(message: 'Saved', kind: ToastKind.success),
      );
      expect(accentBar(), findsNothing);
    });

    testWidgets('shows the red accent  bar for an error toast', (tester) async {
      await pump(
        tester,
        const AppToast.short(message: 'Could not save', kind: ToastKind.error),
      );
      expect(accentBar(), findsOneWidget);
    });

    testWidgets('error icon is tinted with the error colour', (tester) async {
      await pump(
        tester,
        const AppToast.short(
          message: 'Could not save',
          kind: ToastKind.error,
          icon: Icons.error_outline,
        ),
      );
      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.color, AppColors.error);
    });
  });

  group('AppToast.long', () {
    testWidgets('renders message and subtitle', (tester) async {
      await pump(
        tester,
        const AppToast.long(
          message: 'Shopping list created',
          subtitle: 'Honey Sriracha Chicken',
        ),
      );
      expect(find.text('Shopping list created'), findsOneWidget);
      expect(find.text('Honey Sriracha Chicken'), findsOneWidget);
    });

    testWidgets('falls back to a default leading icon when none is given',
        (tester) async {
      await pump(tester, const AppToast.long(message: 'Notice'));
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });


    testWidgets('shows the action label and fires its callback', (tester) async {
      var tapped = false;
      await pump(
        tester,
        AppToast.long(
          message: 'Shopping list created',
          actionLabel: 'View',
          onAction: () => tapped = true,
        ),
      );

      expect(find.text('View'), findsOneWidget);
      await tester.tap(find.text('View'));
      expect(tapped, isTrue);
    });

    testWidgets('removes the action when no callback is given', (tester) async {
      await pump(
        tester,
        const AppToast.long(message: 'Saved', actionLabel: 'View'),
      );
      expect(find.text('View'), findsNothing);
    });

    testWidgets('shows the red accent bar for an error toast', (tester) async {
      await pump(
        tester,
        const AppToast.long(
          message: 'Upload failed',
          kind: ToastKind.error,
        ),
      );
      expect(accentBar(), findsOneWidget);
    });
  });
}