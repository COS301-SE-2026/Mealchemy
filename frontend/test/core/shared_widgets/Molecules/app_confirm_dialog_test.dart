import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/shared_widgets/Molecules/app_confirm_dialog.dart';

void main() {
  //helper to pump a screen with a button that triggers the dialog
  Widget buildTestHarness({
    required void Function(bool? result) onResult,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              final result = await showAppConfirmDialog(
                context: context,
                title: 'Delete item?',
                message: 'This action cannot be undone.',
                confirmLabel: confirmLabel,
                cancelLabel: cancelLabel,
                isDestructive: isDestructive,
              );
              onResult(result);
            },
            child: const Text('Open dialog'),
          ),
        ),
      ),
    );
  }

  testWidgets('displays title and message', (tester) async {
    await tester.pumpWidget(buildTestHarness(onResult: (_) {}));
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();
    expect(find.text('Delete item?'), findsOneWidget);
    expect(find.text('This action cannot be undone.'), findsOneWidget);
  });

  testWidgets('shows default confirm and cancel labels', (tester) async {
    await tester.pumpWidget(buildTestHarness(onResult: (_) {}));
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('shows custom confirm and cancel labels', (tester) async {
    await tester.pumpWidget(buildTestHarness(
      onResult: (_) {},
      confirmLabel: 'Delete',
      cancelLabel: 'Keep it',
    ));

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Keep it'), findsOneWidget);
  });

  testWidgets('tapping confirm returns true and closes dialog',
      (tester) async {
    bool? result;
    await tester.pumpWidget(buildTestHarness(onResult: (r) => result = r));
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(result, true);
    expect(find.text('Delete item?'), findsNothing);
  });

  testWidgets('tapping cancel returns false and closes dialog',
      (tester) async {
    bool? result;
    await tester.pumpWidget(buildTestHarness(onResult: (r) => result = r));
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, false);
    expect(find.text('Delete item?'), findsNothing);
  });
}