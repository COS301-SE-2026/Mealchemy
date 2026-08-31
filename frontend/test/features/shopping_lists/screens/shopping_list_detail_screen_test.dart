import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/core/routes/app_routes.dart';
import 'package:mealchemy/features/shopping_lists/screens/shopping_list_detail_screen.dart';
import 'package:mealchemy/features/shopping_lists/screens/add_shopping_list_item_screen.dart';
import 'package:mealchemy/features/shopping_lists/screens/shopping_lists_screen.dart';
import 'package:mealchemy/features/shopping_lists/widgets/shopping_bottom_action_bar.dart';
import 'package:mealchemy/features/shopping_lists/models/complete_shop_result.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list_item.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';
import 'package:mealchemy/features/shopping_lists/repositories/shopping_list_repository.dart';
import 'package:mealchemy/features/shopping_lists/repositories/mock_shopping_list_repository.dart';
import 'package:mealchemy/features/pantry/providers/pantry_provider.dart';
import 'package:mealchemy/features/pantry/repositories/mock_pantry_repository.dart';

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
  Future<ShoppingList> addRecipeToExistingList({
    required String listId,
    required int recipeId,
    required bool includeAvailablePantryItems,
  }) async {
    throw UnimplementedError();
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
  Future<ShoppingList> updateShoppingList({
    required String listId,
    required String name,
    String status = 'ACTIVE',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ShoppingListItem> addItemToShoppingList({
    required String listId,
    int? ingId,
    String? name,
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
  Future<ShoppingListItem> updateShoppingListItem({
    required String listId,
    required String itemId,
    int? ingId,
    String? name,
    required String quantity,
    required String unit,
    required bool purchased,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<CompleteShopResult> completeShop(String listId) {
    throw UnimplementedError();
  }

  @override
  Future<ShoppingList> generateFromRecipe({
    required int recipeId,
    required String name,
    required bool includeAvailablePantryItems,
  }) async {
    throw UnimplementedError();
  }
}

class _FailingUpdateShoppingListRepository extends MockShoppingListRepository {
  @override
  Future<ShoppingListItem> updateShoppingListItem({
    required String listId,
    required String itemId,
    int? ingId,
    String? name,
    required String quantity,
    required String unit,
    required bool purchased,
  }) async {
    throw Exception('Unable to update item.');
  }
}

class _CompleteShopDeletionRepository extends MockShoppingListRepository {
  _CompleteShopDeletionRepository({
    required this.canDeleteShoppingList,
  });

  final bool canDeleteShoppingList;
  int deleteListCalls = 0;

  @override
  Future<CompleteShopResult> completeShop(String listId) async {
    return CompleteShopResult(
      addedToPantryCount: 1,
      skippedManualItems: const [],
      canDeleteShoppingList: canDeleteShoppingList,
    );
  }

  @override
  Future<void> deleteShoppingList(String listId) async {
    deleteListCalls++;
  }
}

void main() {
  setUpAll(() {
    //disable google font fetching
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpShoppingListDetailScreen(
    WidgetTester tester, {
    String listId = 'general-list',
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
        child: MaterialApp(
          home: ShoppingListDetailScreen(
            listId: listId,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('ShoppingListDetailScreen renders General List items', (
    tester,
  ) async {
    await pumpShoppingListDetailScreen(tester);

    expect(find.text('All Items'), findsOneWidget);
    expect(find.text('GENERAL LIST'), findsOneWidget);
    expect(find.text('PRODUCE'), findsOneWidget);
    expect(find.text('Heirloom Tomatoes'), findsOneWidget);
    expect(find.text('Baby Arugula'), findsOneWidget);
  });

  testWidgets('ShoppingListDetailScreen toggles item checkbox', (tester) async {
    await pumpShoppingListDetailScreen(tester);

    final firstCheckbox = find.byType(Checkbox).first;
    var checkbox = tester.widget<Checkbox>(firstCheckbox);

    expect(checkbox.value, isFalse);

    await tester.tap(firstCheckbox);
    await tester.pumpAndSettle();

    checkbox = tester.widget<Checkbox>(firstCheckbox);

    expect(checkbox.value, isTrue);
  });

  testWidgets('ShoppingListDetailScreen edits item quantity and unit', (
    tester,
  ) async {
    await pumpShoppingListDetailScreen(tester);

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();

    expect(find.text('Edit Shopping List Item'), findsOneWidget);
    expect(find.text('Heirloom Tomatoes'), findsWidgets);

    final quantityField = find.widgetWithText(
      TextField,
      'Quantity',
    );

    expect(quantityField, findsOneWidget);

    await tester.enterText(quantityField, '12.5');

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('kg').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Heirloom Tomatoes updated.'), findsOneWidget);
    expect(find.text('12.5 kg'), findsOneWidget);
  });

  testWidgets('ShoppingListDetailScreen shows item update failure', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingListRepositoryProvider.overrideWithValue(
            _FailingUpdateShoppingListRepository(),
          ),
        ],
        child: const MaterialApp(
          home: ShoppingListDetailScreen(
            listId: 'general-list',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();

    final quantityField = find.widgetWithText(
      TextField,
      'Quantity',
    );

    await tester.enterText(quantityField, '12');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not update the item. Try again.'),
      findsOneWidget,
    );
    expect(find.text('Edit Shopping List Item'), findsOneWidget);
  });

  testWidgets('ShoppingListDetailScreen rejects non-positive edit quantity', (
    tester,
  ) async {
    await pumpShoppingListDetailScreen(tester);

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();

    final quantityField = find.widgetWithText(
      TextField,
      'Quantity',
    );

    await tester.enterText(quantityField, '0');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(
      find.text('Enter a quantity greater than zero.'),
      findsOneWidget,
    );
    expect(find.text('Edit Shopping List Item'), findsOneWidget);
  });

  testWidgets('ShoppingListDetailScreen selects all items', (tester) async {
    await pumpShoppingListDetailScreen(tester);

    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();

    expect(find.byType(Checkbox), findsWidgets);

    final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
    expect(checkboxes.every((checkbox) => checkbox.value == true), isTrue);
  });

  testWidgets('ShoppingListDetailScreen deselects all items', (tester) async {
    await pumpShoppingListDetailScreen(tester);

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

  testWidgets('ShoppingListDetailScreen opens add item entry screen', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/shopping-lists/general-list',
      routes: [
        GoRoute(
          path: AppRoutes.shoppingListDetail,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ShoppingListDetailScreen(listId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.shoppingListAddItem,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return AddShoppingListItemScreen(listId: id);
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

    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();

    expect(find.text('Shopping List Entry'), findsOneWidget);
    expect(find.text('Add Shopping List Item'), findsOneWidget);
    expect(find.text('Catalogue'), findsOneWidget);
    expect(find.text('Custom Item'), findsOneWidget);
  });

  testWidgets('ShoppingListDetailScreen shows update pantry snackbar', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpShoppingListDetailScreen(tester);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Update Pantry'));
    await tester.tap(find.text('Update Pantry'));
    await tester.pumpAndSettle();

    expect(find.textContaining('item sent to pantry'), findsOneWidget);

    //mock response says the list cant be deleted
    expect(find.text('Shopping List Empty'), findsNothing);
  });

  testWidgets('keeps empty list when user declines deletion', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repository = _CompleteShopDeletionRepository(
      canDeleteShoppingList: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingListRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: ShoppingListDetailScreen(
            listId: 'general-list',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    //mock General List already contains one purchased item
    await tester.ensureVisible(find.text('Update Pantry'));
    await tester.tap(find.text('Update Pantry'));
    await tester.pumpAndSettle();

    expect(find.text('Shopping List Empty'), findsOneWidget);
    expect(find.text('Keep List'), findsOneWidget);
    expect(find.text('Delete List'), findsOneWidget);

    await tester.tap(find.text('Keep List'));
    await tester.pumpAndSettle();

    expect(repository.deleteListCalls, 0);
    expect(find.text('GENERAL LIST'), findsOneWidget);
  });

  testWidgets('deletes empty list when user confirms deletion', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repository = _CompleteShopDeletionRepository(
      canDeleteShoppingList: true,
    );

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
            return ShoppingListDetailScreen(
              listId: state.pathParameters['id']!,
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingListRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Update Pantry'));
    await tester.tap(find.text('Update Pantry'));
    await tester.pumpAndSettle();

    expect(find.text('Shopping List Empty'), findsOneWidget);

    await tester.tap(find.text('Delete List'));
    await tester.pumpAndSettle();

    expect(repository.deleteListCalls, 1);
    expect(find.text('Shopping Lists'), findsOneWidget);
  });

  testWidgets(
    'ShoppingListDetailScreen refreshes pantry data after update pantry',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var pantryRepositoryBuildCount = 0;

      final container = ProviderContainer(
        overrides: [
          shoppingListRepositoryProvider.overrideWithValue(
            MockShoppingListRepository(),
          ),
          pantryRepositoryProvider.overrideWith((ref) {
            pantryRepositoryBuildCount++;
            return MockPantryRepository();
          }),
        ],
      );
      addTearDown(container.dispose);

      // Load the pantry once to represent pantry data already cached in memory.
      await container.read(pantryStateProvider.future);

      expect(pantryRepositoryBuildCount, 1);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ShoppingListDetailScreen(
              listId: 'general-list',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Update Pantry'));
      await tester.tap(find.text('Update Pantry'));
      await tester.pumpAndSettle();

      //reading the invalidated pantry state must create a fresh repo, so API repo cant return its old ingredient cache
      await container.read(pantryStateProvider.future);

      expect(pantryRepositoryBuildCount, 2);
    },
  );

  testWidgets('ShoppingListDetailScreen renders not found state', (
    tester,
  ) async {
    await pumpShoppingListDetailScreen(tester, listId: 'unknown-list');

    expect(find.text('Shopping list not found.'), findsOneWidget);
  });

  testWidgets(
    'ShoppingListDetailScreen keeps cached items and disables writes offline',
    (tester) async {
      await pumpShoppingListDetailScreen(tester, isOffline: true);

      expect(find.text('Heirloom Tomatoes'), findsOneWidget);

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox).first);
      expect(checkbox.onChanged, isNull);

      final actionBar = tester.widget<ShoppingBottomActionBar>(
        find.byType(ShoppingBottomActionBar),
      );
      expect(actionBar.onAddTap, isNull);
      expect(actionBar.onMicTap, isNull);

      final menu = tester.widget<PopupMenuButton<String>>(
        find.byType(PopupMenuButton<String>),
      );
      expect(menu.enabled, isFalse);

      final updatePantry = tester.widget<InkWell>(
        find
            .ancestor(
              of: find.text('Update Pantry'),
              matching: find.byType(InkWell),
            )
            .first,
      );
      expect(updatePantry.onTap, isNull);
    },
  );

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

    //waits for mock data to finish loading
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(find.text('Shopping Lists'), findsOneWidget);
  });

  testWidgets('ShoppingListDetailScreen loads full list detail with items',
      (tester) async {
    await pumpShoppingListDetailScreen(tester, listId: 'weekly-groceries');

    //detail screen fetches the full list, so its items should be visible
    expect(find.text('Organic Milk'), findsOneWidget);
    expect(find.text('Free Range Eggs'), findsOneWidget);
  });
}
