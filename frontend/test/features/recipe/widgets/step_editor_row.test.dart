import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/recipe/widgets/step_editor_row.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpRow(
    WidgetTester tester, {
    int stepNumber = 1,
    TextEditingController? controller,
    VoidCallback? onRemove,
    bool showError = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StepEditorRow(
            stepNumber: stepNumber,
            controller: controller ?? TextEditingController(),
            onRemove: onRemove ?? () {},
            showError: showError,
          ),
        ),
      ),
    );
  }

  testWidgets('renders the step number badge and the empty-state hint',
      (tester) async {
    await pumpRow(tester, stepNumber: 3);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Describe this step'), findsOneWidget);
  });

  testWidgets('typing routes through the controller', (tester) async {
    final controller = TextEditingController();
    await pumpRow(tester, controller: controller);

    await tester.enterText(find.byType(TextField), 'Sear the beef.');
    expect(controller.text, 'Sear the beef.');
  });

  testWidgets('tapping remove fires onRemove', (tester) async {
    var removed = false;
    await pumpRow(tester, onRemove: () => removed = true);

    await tester.tap(find.byTooltip('Remove'));
    expect(removed, isTrue);
  });

  testWidgets('error text is shown only when showError is true',
      (tester) async {
    await pumpRow(tester, showError: false);
    expect(find.text('Step text is required.'), findsNothing);

    await pumpRow(tester, showError: true);
    expect(find.text('Step text is required.'), findsOneWidget);
  });
}