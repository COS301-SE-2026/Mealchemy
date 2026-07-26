import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/features/shopping_lists/screens/shopping_list_detail_screen.dart';
import 'package:mealchemy/features/shopping_lists/screens/shopping_lists_screen.dart';
import 'package:mealchemy/features/shopping_lists/models/complete_shop_result.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list_item.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';
import 'package:mealchemy/features/shopping_lists/repositories/shopping_list_repository.dart';

class _DeleteMenuShoppingListRepository implements ShoppingListRepository {
  @override
  Future<List<ShoppingList>> getShoppingLists() async {
    return [
      ShoppingList(
        id: '1',
        shoppingListId: 1,
        userId: 3,
        title: 'General List',
        subtitle: '2 items added by you',
        section: 'FAVORITES',
        iconType: 'list',
        status: 'ACTIVE',
        createdAt: DateTime.parse('2026-07-13T14:00:00Z'),
        items: const [
          ShoppingListItem(
            id: '10',
            itemId: 10,
            shoppingListId: 1,
            name: 'Greek Yogurt',
            quantity: '907 g',
            unit: 'g',
            category: 'MANUAL',
          ),
          ShoppingListItem(
            id: '11',
            itemId: 11,
            shoppingListId: 1,
            name: 'Fresh Basil',
            quantity: '1 bunch',
            unit: 'bunch',
            category: 'MANUAL',
          ),
        ],
      ),
    ];
  }

  @override
  Future<ShoppingList?> getShoppingListById(String id) async {
    final lists = await getShoppingLists();
    return lists.firstWhere((list) => list.id == id);
  }

  @override
  Future<List<ShoppingListItem>> selectAllItems(String listId) async {
    final list = await getShoppingListById(listId);
    return list!.items.map((item) => item.copyWith(checked: true)).toList();
  }

  @override
  Future<List<ShoppingListItem>> deselectAllItems(String listId) async {
    final list = await getShoppingListById(listId);
    return list!.items.map((item) => item.copyWith(checked: false)).toList();
  }

  @override
  Future<void> deleteShoppingListItems({
    required String listId,
    required List<int> itemIds,
  }) async {
    //fake backend accepts the delete request
  }

  @override
  Future<void> deleteShoppingList(String listId) async {
    //not used in this detail screen test
  }

  @override
  Future<ShoppingList> createShoppingList({
    required String name,
    String status = 'ACTIVE',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ShoppingListItem> addItemToShoppingList({
    required String listId,
    required String name,
    required String quantity,
    required String unit,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ShoppingListItem> updateItemPurchased({
    required String listId,
    required String itemId,
    required bool purchased,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<CompleteShopResult> completeShop(String listId) {
    throw UnimplementedError();
  }
}

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

  testWidgets('ShoppingListDetailScreen selects all items', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ShoppingListDetailScreen(listId: 'general-list'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();

    expect(find.byType(Checkbox), findsWidgets);

    final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
    expect(checkboxes.every((checkbox) => checkbox.value == true), isTrue);
  });

  testWidgets('ShoppingListDetailScreen deselects all items', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ShoppingListDetailScreen(listId: 'general-list'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Deselect'));
    await tester.pumpAndSettle();

    final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
    expect(checkboxes.every((checkbox) => checkbox.value == false), isTrue);
  });

  testWidgets(
      'ShoppingListDetailScreen shows message when deleting with no selection',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingListRepositoryProvider.overrideWithValue(
            _DeleteMenuShoppingListRepository(),
          ),
        ],
        child: const MaterialApp(
          home: ShoppingListDetailScreen(listId: '1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete selected'));
    await tester.pumpAndSettle();

    expect(find.text('No selected items to delete.'), findsOneWidget);
  });

  testWidgets('ShoppingListDetailScreen deletes selected items from menu',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingListRepositoryProvider.overrideWithValue(
            _DeleteMenuShoppingListRepository(),
          ),
        ],
        child: const MaterialApp(
          home: ShoppingListDetailScreen(listId: '1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete selected'));
    await tester.pumpAndSettle();

    expect(find.text('2 selected items deleted.'), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
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

    expect(find.textContaining('item sent to pantry'), findsOneWidget);
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
