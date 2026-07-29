import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_input_dialog.dart';

void main() {
  //helper to pump a screen with a button that triggers the dialog
  Widget buildTestHarness({
    required void Function(String? result) onResult,
    String confirmLabel = 'Save',
    String? initialValue,
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              final result = await showAppInputDialog(
                context: context,
                title: 'Rename item',
                label: 'Name',
                hint: 'Enter a name',
                confirmLabel: confirmLabel,
                initialValue: initialValue,
              );
              onResult(result);
            },
            child: const Text('Open dialog'),
          ),
        ),
      ),
    );
  }

  testWidgets('displays title', (tester) async {
    await tester.pumpWidget(buildTestHarness(onResult: (_) {}));
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Rename item'), findsOneWidget);
  });

  testWidgets('pre-fills the field with initialValue', (tester) async {
    await tester.pumpWidget(
      buildTestHarness(onResult: (_) {}, initialValue: 'Mutombo'),
    );
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Mutombo'), findsOneWidget);
  });

  testWidgets('shows custom confirm label', (tester) async {
    await tester.pumpWidget(
      buildTestHarness(onResult: (_) {}, confirmLabel: 'Update'),
    );
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Update'), findsOneWidget);
  });

  testWidgets('submitting empty field shows validation error and stays open',
      (tester) async {
    String? result = 'unset';
    await tester.pumpWidget(buildTestHarness(onResult: (r) => result = r));
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('This field is required.'), findsOneWidget);
    expect(result, 'unset'); // dialog never popped
  });

  testWidgets('typing after error clears the validation message',
      (tester) async {
    await tester.pumpWidget(buildTestHarness(onResult: (_) {}));
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'New name');
    await tester.pumpAndSettle();

    expect(find.text('This field is required.'), findsNothing);
  });

  testWidgets('submitting with text returns trimmed value and closes dialog',
      (tester) async {
    String? result;
    await tester.pumpWidget(buildTestHarness(onResult: (r) => result = r));
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '  New name  ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, 'New name');
    expect(find.text('Rename item'), findsNothing);
  });

  testWidgets('tapping cancel returns null and closes dialog', (tester) async {
    String? result = 'unset';
    await tester.pumpWidget(buildTestHarness(onResult: (r) => result = r));
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(find.text('Rename item'), findsNothing);
  });
}