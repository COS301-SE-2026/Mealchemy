import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/features/shopping_lists/screens/shopping_list_detail_screen.dart';
import 'package:mealchemy/features/shopping_lists/screens/shopping_lists_screen.dart';
import 'package:mealchemy/features/shopping_lists/widgets/shopping_list_row.dart';

void main() {
  setUpAll(() {
    //disable font fetching
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('ShoppingListsScreen renders shopping lists overview', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ShoppingListsScreen(),
        ),
      ),
    );

    //waits for mock data to finish loading
    await tester.pumpAndSettle();

    expect(find.text('Shopping Lists'), findsOneWidget);
    expect(find.text('General List'), findsOneWidget);
    expect(find.text('Weekly Groceries'), findsOneWidget);
    expect(find.text('FROM YOUR RECIPES'), findsOneWidget);
  });

  testWidgets('ShoppingListsScreen filters lists using search', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ShoppingListsScreen(),
        ),
      ),
    );

    //waits for mock data to finish loading
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'general');
    await tester.pumpAndSettle();

    expect(find.text('General List'), findsOneWidget);
    expect(find.text('Weekly Groceries'), findsNothing);
  });

  testWidgets('ShoppingListsScreen clears search query', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ShoppingListsScreen(),
        ),
      ),
    );

    //waits for mock data to finish loading
    await tester.pumpAndSettle();

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
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    //waits for mock data to finish loading
    await tester.pumpAndSettle();

    await tester.tap(find.text('General List'));
    await tester.pumpAndSettle();

    expect(find.text('All Items'), findsOneWidget);
    expect(find.text('Heirloom Tomatoes'), findsOneWidget);
  });
  testWidgets(
      'ShoppingListsScreen creates new list from floating action button',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ShoppingListsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

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
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ShoppingListsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

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
}
