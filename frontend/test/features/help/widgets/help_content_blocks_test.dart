import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/help/widgets/help_content_blocks.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget host(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );
  }

  group('HelpBodyText', () {
    testWidgets('rendes its text', (tester) async {
      await tester.pumpWidget(host(const HelpBodyText('Some help copy.')));
      await tester.pumpAndSettle();
      expect(find.text('Some help copy.'), findsOneWidget);
    });
  });

  group('HelpIconRow', () {
    testWidgets('renders the icon and value', (tester) async {
      await tester.pumpWidget(host(const HelpIconRow(
        icon: Icons.mail_outline_rounded,
        value: 'support@mealchemy.com',
      )));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.mail_outline_rounded), findsOneWidget);
      expect(find.text('support@mealchemy.com'), findsOneWidget);
    });

    testWidgets('shows the label when one is given', (tester) async {
      await tester.pumpWidget(host(const HelpIconRow(
        icon: Icons.phone,
        label: 'Phone',
        value: '0840941479',
      )));
      await tester.pumpAndSettle();

      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('0840941479'), findsOneWidget);
    });

    testWidgets('omits the label when none is given', (tester) async {
      await tester.pumpWidget(host(const HelpIconRow(
        icon: Icons.phone,
        value: '0840941479',
      )));
      await tester.pumpAndSettle();
      expect(find.text('0840941479'), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });
  });

  group('HelpIconBullet', () {
    testWidgets('renders the icon and text', (tester) async {
      await tester.pumpWidget(host(const HelpIconBullet(
        icon: Icons.add,
        text: 'Tap the plus to add a recipe.',
      )));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Tap the plus to add a recipe.'), findsOneWidget);
    });
  });
}