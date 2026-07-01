import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/features/shopping_lists/screens/shopping_list_detail_screen.dart';
import 'package:mealchemy/features/shopping_lists/screens/shopping_lists_screen.dart';

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
}