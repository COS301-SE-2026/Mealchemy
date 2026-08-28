import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list_item.dart';
import 'package:mealchemy/features/shopping_lists/widgets/shopping_list_row.dart';

void main() {
  setUpAll(() {
    //disable google fonts
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final list = ShoppingList(
    id: 'general-list',
    title: 'General List',
    subtitle: '2 items added by you',
    section: 'FAVORITES',
    iconType: 'list',
    items: const [
      ShoppingListItem(
        id: 'tomatoes',
        name: 'Heirloom Tomatoes',
        quantity: '8g',
        category: 'PRODUCE',
      ),
      ShoppingListItem(
        id: 'arugula',
        name: 'Baby Arugula',
        quantity: '142 g',
        category: 'PRODUCE',
      ),
    ],
  );

  testWidgets('ShoppingListRow renders list details', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShoppingListRow(
            list: list,
          ),
        ),
      ),
    );

    expect(find.text('General List'), findsOneWidget);
    expect(find.byIcon(Icons.list_alt), findsOneWidget);
  });

  testWidgets('ShoppingListRow calls onTap when row is tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShoppingListRow(
            list: list,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('General List'));

    expect(tapped, isTrue);
  });

  testWidgets('ShoppingListRow renders favorite star icon', (tester) async {
    final favouriteList = list.copyWith(
      iconType: 'star',
      favourite: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShoppingListRow(
            list: favouriteList,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('ShoppingListRow displays backend overview item count', (
    tester,
  ) async {
    final overviewList = ShoppingList(
      id: '7',
      shoppingListId: 7,
      userId: 3,
      numItems: 5,
      title: 'Weekend Braai',
      subtitle: '0 items added by you',
      section: 'OTHER LISTS',
      iconType: 'list',

      //overview endpoint returns metadata only
      items: const [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShoppingListRow(
            list: overviewList,
          ),
        ),
      ),
    );

    expect(find.text('Weekend Braai'), findsOneWidget);
    expect(find.text('5 items added by you'), findsOneWidget);
    expect(overviewList.items, isEmpty);
  });
}
