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
    //disable google font fetching
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('ShoppingListDetailScreen renders General List items', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ShoppingListDetailScreen(
            listId: 'general-list',
          ),
        ),
      ),
    );

    //waits for mock data to finish loading
    await tester.pumpAndSettle();

    expect(find.text('All Items'), findsOneWidget);
    expect(find.text('GENERAL LIST'), findsOneWidget);
    expect(find.text('PRODUCE'), findsOneWidget);
    expect(find.text('Heirloom Tomatoes'), findsOneWidget);
    expect(find.text('Baby Arugula'), findsOneWidget);
  });

  testWidgets('ShoppingListDetailScreen toggles item checkbox', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ShoppingListDetailScreen(
            listId: 'general-list',
          ),
        ),
      ),
    );

    //waits for mock data to finish loading
    await tester.pumpAndSettle();

    final firstCheckbox = find.byType(Checkbox).first;
    var checkbox = tester.widget<Checkbox>(firstCheckbox);

    expect(checkbox.value, isFalse);

    await tester.tap(firstCheckbox);
    await tester.pumpAndSettle();

    checkbox = tester.widget<Checkbox>(firstCheckbox);

    expect(checkbox.value, isTrue);
  });

  testWidgets('ShoppingListDetailScreen adds item from dialog', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ShoppingListDetailScreen(
            listId: 'general-list',
          ),
        ),
      ),
    );

    //waits for mock data to finish loading
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Item name'), 'Fresh Basil');
    await tester.enterText(
        find.widgetWithText(TextField, 'Quantity'), '1 bunch');
    await tester.enterText(
        find.widgetWithText(TextField, 'Category'), 'Produce');

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    //new item is appended lower in list, so scroll until visible
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Fresh Basil'), findsOneWidget);
    expect(find.text('1 bunch'), findsOneWidget);
  });

  testWidgets('ShoppingListDetailScreen shows update pantry snackbar', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ShoppingListDetailScreen(
            listId: 'general-list',
          ),
        ),
      ),
    );

    //waits for mock data to finish loading
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Update Pantry'));
    await tester.tap(find.text('Update Pantry'));
    await tester.pumpAndSettle();

    expect(find.textContaining('items sent to pantry'), findsOneWidget);
  });

  testWidgets('ShoppingListDetailScreen renders not found state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ShoppingListDetailScreen(
            listId: 'unknown-list',
          ),
        ),
      ),
    );

    //waits for mock data to finish loading
    await tester.pumpAndSettle();

    expect(find.text('Shopping list not found.'), findsOneWidget);
  });

  testWidgets('ShoppingListDetailScreen back button returns to overview', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/shopping-lists/general-list',
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

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(find.text('Shopping Lists'), findsOneWidget);
  });
}
