import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/shopping_lists/widgets/shopping_bottom_action_bar.dart';

void main() {
  testWidgets('shows only the add action', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ShoppingBottomActionBar()),
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.mic_none), findsNothing);
    expect(find.byIcon(Icons.sort), findsNothing);
  });

  testWidgets('add action invokes its callback', (tester) async {
    var calls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShoppingBottomActionBar(
            onAddTap: () => calls++,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));

    expect(calls, 1);
  });

  testWidgets('add action is disabled without a callback', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ShoppingBottomActionBar()),
      ),
    );

    final button = tester.widget<InkWell>(find.byType(InkWell));
    expect(button.onTap, isNull);
  });
}
