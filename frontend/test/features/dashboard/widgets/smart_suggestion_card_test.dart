import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/features/dashboard/providers/shopping_list_provider.dart';
import 'package:mealchemy/features/dashboard/widgets/smart_suggestion_card.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list.dart';

ShoppingList _list({required String title, required int count}) => ShoppingList(
      id: 't',
      title: title,
      subtitle: '',
      section: 'OTHER LISTS',
      iconType: 'list',
      numItems: count,
      items: const [],
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget host(ShoppingList? newest) => ProviderScope(
        overrides: [newListProvider.overrideWithValue(newest)],
        child: const MaterialApp(
          home: Scaffold(body: SmartSuggestionCard()),
        ),
      );

  testWidgets('always shows the smart suggestion label', (tester) async {
    await tester.pumpWidget(host(_list(title: 'Weekend Cooking', count: 8)));
    expect(find.text('SMART SUGGESTION'), findsOneWidget);
  });

  testWidgets('shows the item count message for a list with items',
      (tester) async {
    await tester.pumpWidget(host(_list(title: 'Weekend Cooking', count: 8)));
    expect(
      find.text("You've got 8 items to buy on Weekend Cooking."),
      findsOneWidget,
    );
  });

  testWidgets('uses the singular noun for a single item', (tester) async {
    await tester.pumpWidget(host(_list(title: 'Quick Trip', count: 1)));
    expect(
      find.text("You've got 1 item to buy on Quick Trip."),
      findsOneWidget,
    );
  });

  testWidgets('shows the empty message for a list with no items',
      (tester) async {
    await tester.pumpWidget(host(_list(title: 'Weekend Cooking', count: 0)));
    expect(
      find.text('Weekend Cooking is empty. Add items to get started.'),
      findsOneWidget,
    );
  });

  testWidgets('shows the create prompt when there are no lists',
      (tester) async {
    await tester.pumpWidget(host(null));
    expect(find.text('No shopping lists yet.'), findsOneWidget);
    expect(find.text('Create your first list'), findsOneWidget);
  });

  testWidgets('tapping the create prompt opens the input dialog',
      (tester) async {
    await tester.pumpWidget(host(null));
    await tester.tap(find.text('Create your first list'));
    await tester.pumpAndSettle();
    expect(find.text('New shopping list'), findsOneWidget);
  });
}