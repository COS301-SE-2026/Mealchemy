import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list_item.dart';
import 'package:mealchemy/features/shopping_lists/widgets/shopping_item_row.dart';

void main() {
  setUpAll(() {
    //disable google fonts during testing
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  //row shows item name, quantity, checkbox
  testWidgets('ShoppingItemRow renders item details', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShoppingItemRow(
            item: ShoppingListItem(
              id: 'baby-arugula',
              name: 'Baby Arugula',
              quantity: '142 g',
              category: 'PRODUCE',
            ),
            onChanged: (_) {},
          ),
        ),
      ),
    );

    //details, checkbox
    expect(find.text('Baby Arugula'), findsOneWidget);
    expect(find.text('142 g'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
  });

  testWidgets('ShoppingItemRow calls onChanged when checkbox is tapped', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShoppingItemRow(
            item: const ShoppingListItem(
              id: 'baby-arugula',
              name: 'Baby Arugula',
              quantity: '142 g',
              category: 'PRODUCE',
            ),
            onChanged: (_) => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Checkbox));

    expect(tapped, isTrue);
  });

  testWidgets('ShoppingItemRow disables its checkbox without a callback', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShoppingItemRow(
            item: ShoppingListItem(
              id: 'baby-arugula',
              name: 'Baby Arugula',
              quantity: '142 g',
              category: 'PRODUCE',
            ),
          ),
        ),
      ),
    );

    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.onChanged, isNull);
  });

  testWidgets('ShoppingItemRow renders checked item', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShoppingItemRow(
            item: ShoppingListItem(
              id: 'shallots',
              name: 'Shallots',
              quantity: '2 ct',
              category: 'PRODUCE',
              checked: true,
            ),
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));

    expect(checkbox.value, isTrue);
    expect(find.text('Shallots'), findsOneWidget);
  });

  testWidgets('ShoppingItemRow calls onEdit when edit icon is tapped', (
    tester,
  ) async {
    var editTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShoppingItemRow(
            item: const ShoppingListItem(
              id: 'baby-arugula',
              name: 'Baby Arugula',
              quantity: '142 g',
              category: 'PRODUCE',
            ),
            onChanged: (_) {},
            onEdit: () => editTapped = true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_outlined));

    expect(editTapped, isTrue);
  });
}
