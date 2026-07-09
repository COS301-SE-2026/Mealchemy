import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/shopping_lists/widgets/shopping_bottom_action_bar.dart';

void main() {
  testWidgets('ShoppingBottomActionBar renders action buttons', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShoppingBottomActionBar(),
        ),
      ),
    );

    expect(find.byIcon(Icons.mic_none), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.sort), findsOneWidget);
  });

  testWidgets('ShoppingBottomActionBar calls action callbacks', (tester) async {
    var micTapped = false;
    var addTapped = false;
    var filterTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShoppingBottomActionBar(
            onMicTap: () => micTapped = true,
            onAddTap: () => addTapped = true,
            onFilterTap: () => filterTapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.tap(find.byIcon(Icons.add));
    await tester.tap(find.byIcon(Icons.sort));

    expect(micTapped, isTrue);
    expect(addTapped, isTrue);
    expect(filterTapped, isTrue);
  });
}
