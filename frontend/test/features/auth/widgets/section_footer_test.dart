import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/theme/app_theme.dart';
import 'package:mealchemy/features/auth/widgets/section_footer.dart';

void main() {
  Widget buildWidget() {
    return MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: SingleChildScrollView(child: SectionFooter()),
      ),
    );
  }

  group('SectionFooter', () {
    testWidgets('renders Kitchen Intelligence label', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('KITCHEN INTELLIGENCE'), findsOneWidget);
    });

testWidgets('renders description text', (tester) async {
  await tester.pumpWidget(buildWidget());
  expect(find.byType(RichText), findsWidgets);
});

testWidgets('renders Smart Substitution text', (tester) async {
  await tester.pumpWidget(buildWidget());
  final richTexts = tester.widgetList<RichText>(find.byType(RichText));
  final hasSmartSubstitution = richTexts.any(
    (widget) => widget.text.toPlainText().contains('Smart Substitution'),
  );
  expect(hasSmartSubstitution, true);
});

testWidgets('renders copyright text', (tester) async {
  await tester.pumpWidget(buildWidget());
  final richTexts = tester.widgetList<RichText>(find.byType(RichText));
  final hasCopyright = richTexts.any(
    (widget) => widget.text.toPlainText().contains('2026 MEALCHEMY'),
  );
  expect(hasCopyright, true);
});

    testWidgets('renders privacy link', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('PRIVACY'), findsOneWidget);
    });

    testWidgets('renders terms link', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('TERMS'), findsOneWidget);
    });
  });
}
