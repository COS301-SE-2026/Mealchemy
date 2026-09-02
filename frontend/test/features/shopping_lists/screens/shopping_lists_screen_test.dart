import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/features/shopping_lists/screens/shopping_list_detail_screen.dart';
import 'package:mealchemy/features/shopping_lists/screens/shopping_lists_screen.dart';
import 'package:mealchemy/features/shopping_lists/widgets/shopping_list_row.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';
import 'package:mealchemy/features/shopping_lists/repositories/mock_shopping_list_repository.dart';

void main() {
  setUpAll(() {
    //disable font fetching
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpShoppingListsScreen(
    WidgetTester tester, {
    bool isOffline = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          offlineReadOnlyProvider.overrideWithValue(isOffline),
          shoppingListRepositoryProvider.overrideWithValue(
            MockShoppingListRepository(),
          ),
        ],
        child: const MaterialApp(
          home: ShoppingListsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('ShoppingListsScreen renders shopping lists overview', (
    tester,
  ) async {
    await pumpShoppingListsScreen(tester);

    expect(find.text('Shopping Lists'), findsOneWidget);
    expect(find.text('General List'), findsOneWidget);
    expect(find.text('Weekly Groceries'), findsOneWidget);
    expect(find.text('FROM YOUR RECIPES'), findsOneWidget);
  });

  testWidgets(
    'ShoppingListsScreen keeps cached reads and disables writes offline',
    (tester) async {
      await pumpShoppingListsScreen(tester, isOffline: true);

      expect(find.text('General List'), findsOneWidget);

      final row = tester.widget<ShoppingListRow>(
        find.ancestor(
          of: find.text('General List'),
          matching: find.byType(ShoppingListRow),
        ),
      );
      expect(row.mutationsEnabled, isFalse);

      final addButton = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      expect(addButton.onPressed, isNull);

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'weekly');
      await tester.pumpAndSettle();

      expect(find.text('Weekly Groceries'), findsOneWidget);
      expect(find.text('General List'), findsNothing);
    },
  );

  testWidgets('ShoppingListsScreen filters lists using search', (tester) async {
    await pumpShoppingListsScreen(tester);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'general');
    await tester.pumpAndSettle();

    expect(find.text('General List'), findsOneWidget);
    expect(find.text('Weekly Groceries'), findsNothing);
  });

  testWidgets('ShoppingListsScreen clears search query', (tester) async {
    await pumpShoppingListsScreen(tester);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'general');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('General List'), findsOneWidget);
    expect(find.text('Weekly Groceries'), findsOneWidget);
  });

  testWidgets('ShoppingListsScreen navigates to General List detail', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRoutes.shoppingLists,
      routes: [
        GoRoute(
          path: AppRoutes.shoppingLists,
          builder: (context, state) => const ShoppingListsScreen(),
        ),
        GoRoute(
          path: AppRoutes.shoppingListDetail,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ShoppingListDetailScreen(listId: id);
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingListRepositoryProvider.overrideWithValue(
            MockShoppingListRepository(),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('General List'));
    await tester.pumpAndSettle();

    expect(find.text('All Items'), findsOneWidget);
    expect(find.text('Heirloom Tomatoes'), findsOneWidget);
  });
  testWidgets(
      'ShoppingListsScreen creates new list from floating action button',
      (tester) async {
    await pumpShoppingListsScreen(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Create Shopping List'), findsOneWidget);
    expect(find.text('List name'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'List name'),
      'Weekend Braai',
    );

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Weekend Braai created.'), findsOneWidget);

    //new list is appended lower in the overview, so scroll until it is visible
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Weekend Braai'), findsOneWidget);
  });

  testWidgets('ShoppingListsScreen deletes list from row menu', (tester) async {
    await pumpShoppingListsScreen(tester);

    expect(find.text('General List'), findsOneWidget);

    final generalListRow = find.ancestor(
      of: find.text('General List'),
      matching: find.byType(ShoppingListRow),
    );

    await tester.tap(
      find.descendant(
        of: generalListRow,
        matching: find.byIcon(Icons.more_vert),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete list'));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('General List'), findsNothing);
  });

  testWidgets('ShoppingListsScreen edits list name from row menu',
      (tester) async {
    await pumpShoppingListsScreen(tester);

    expect(find.text('General List'), findsOneWidget);

    final generalListRow = find.ancestor(
      of: find.text('General List'),
      matching: find.byType(ShoppingListRow),
    );

    await tester.tap(
      find.descendant(
        of: generalListRow,
        matching: find.byIcon(Icons.more_vert),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit name'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Shopping List'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'List name'),
      'Weekend Braai',
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Weekend Braai'), findsOneWidget);
    expect(find.text('General List'), findsNothing);
  });
}
