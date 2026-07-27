import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list_item.dart';
import 'package:mealchemy/features/shopping_lists/models/complete_shop_result.dart';
import 'package:mealchemy/features/shopping_lists/repositories/shopping_list_repository.dart';

class _ApiShapedShoppingListRepository implements ShoppingListRepository {
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
  Future<ShoppingList> createShoppingList({
    required String name,
    String status = 'ACTIVE',
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ShoppingList> updateShoppingList({
    required String listId,
    required String name,
    String status = 'ACTIVE',
  }) async {
    final list = await getShoppingListById(listId);

    return list!.copyWith(
      title: name.trim(),
      status: status,
    );
  }

  @override
  Future<ShoppingListItem> addItemToShoppingList({
    required String listId,
    required String name,
    required String quantity,
    required String unit,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ShoppingListItem> updateItemPurchased({
    required String listId,
    required String itemId,
    required bool purchased,
  }) async {
    final list = await getShoppingListById(listId);
    final item = list!.items.firstWhere((item) => item.id == itemId);
    return item.copyWith(checked: purchased);
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
    //pretend the backend accepted the batch delete request
  }

  @override
  Future<void> deleteShoppingList(String listId) async {
    //not used in this provider test
  }
  @override
  Future<CompleteShopResult> completeShop(String listId) async {
    throw UnimplementedError();
  }
}

void main() {
  //loads mock shopping lists into provider state
  test('shoppingListsProvider loads shopping lists', () async {
    //container used to read Riverpod providers in tests
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = await container.read(shoppingListsProvider.future);

    expect(state.lists, isNotEmpty);
    expect(state.getListById('general-list'), isNotNull);
  });

  //checks/unchecks item in provider state
  test('shoppingListsProvider toggles item checked state', () async {
    //container used to read Riverpod providers in tests
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(shoppingListsProvider.future);

    final notifier = container.read(shoppingListsProvider.notifier);

    await notifier.toggleItemChecked(
      listId: 'general-list',
      itemId: 'baby-arugula',
    );

    final updatedState = container.read(shoppingListsProvider).value!;
    final list = updatedState.getListById('general-list')!;
    final item = list.items.firstWhere((item) => item.id == 'baby-arugula');

    expect(item.checked, isTrue);
  });

  //selects every item in one shopping list
  test('shoppingListsProvider selects all items in a list', () async {
    //container used to read Riverpod providers in tests
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(shoppingListsProvider.future);

    final notifier = container.read(shoppingListsProvider.notifier);

    await notifier.selectAllItems('general-list');

    final updatedState = container.read(shoppingListsProvider).value!;
    final list = updatedState.getListById('general-list')!;

    expect(list.items, isNotEmpty);
    expect(list.items.every((item) => item.checked), isTrue);
  });

  //clears every selected item in one shopping list
  test('shoppingListsProvider deselects all items in a list', () async {
    //container used to read Riverpod providers in tests
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(shoppingListsProvider.future);

    final notifier = container.read(shoppingListsProvider.notifier);

    await notifier.selectAllItems('general-list');
    await notifier.deselectAllItems('general-list');

    final updatedState = container.read(shoppingListsProvider).value!;
    final list = updatedState.getListById('general-list')!;

    expect(list.items, isNotEmpty);
    expect(list.items.every((item) => item.checked), isFalse);
  });

  //deletes checked API-shaped items from one shopping list
  test('shoppingListsProvider deletes selected items from a list', () async {
    //this fake gives items real backend itemIds, like the API does
    final container = ProviderContainer(
      overrides: [
        shoppingListRepositoryProvider.overrideWithValue(
          _ApiShapedShoppingListRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(shoppingListsProvider.future);

    final notifier = container.read(shoppingListsProvider.notifier);

    await notifier.selectAllItems('1');
    await notifier.deleteSelectedItems('1');

    final updatedState = container.read(shoppingListsProvider).value!;
    final list = updatedState.getListById('1')!;

    expect(list.items, isEmpty);
  });

  //adds new item to provider state
  test('shoppingListsProvider adds item to list', () async {
    //container used to read Riverpod providers in tests
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(shoppingListsProvider.future);

    final notifier = container.read(shoppingListsProvider.notifier);

    await notifier.addItemToList(
      listId: 'general-list',
      name: 'Fresh Basil',
      quantity: '1 bunch',
      category: 'Produce',
    );

    final updatedState = container.read(shoppingListsProvider).value!;
    final list = updatedState.getListById('general-list')!;

    expect(list.items.any((item) => item.name == 'Fresh Basil'), isTrue);
    expect(list.items.last.category, 'MANUAL');
    expect(list.items.last.quantity, '1 bunch');
    expect(list.items.last.unit, 'bunch');
  });

  //updates search query, filters shopping lists
  test('shoppingListsProvider filters shopping lists by search query',
      () async {
    //container used to read Riverpod providers in tests
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(shoppingListsProvider.future);

    final notifier = container.read(shoppingListsProvider.notifier);

    notifier.updateSearchQuery('general');

    final updatedState = container.read(shoppingListsProvider).value!;

    expect(updatedState.searchQuery, 'general');
    expect(updatedState.filteredLists.length, 1);
    expect(updatedState.filteredLists.first.id, 'general-list');
  });

  //resets shopping lists to mock data
  test('shoppingListsProvider resets shopping lists', () async {
    //container used to read Riverpod providers in tests
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(shoppingListsProvider.future);

    final notifier = container.read(shoppingListsProvider.notifier);

    await notifier.addItemToList(
      listId: 'general-list',
      name: 'Fresh Basil',
      quantity: '1 bunch',
      category: 'Produce',
    );

    await notifier.resetShoppingLists();

    final resetState = container.read(shoppingListsProvider).value!;
    final list = resetState.getListById('general-list')!;

    expect(list.items.any((item) => item.name == 'Fresh Basil'), isFalse);
  });
  test('shoppingListsProvider completes shop and removes checked items',
      () async {
    //container used to read Riverpod providers in tests
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(shoppingListsProvider.future);

    final notifier = container.read(shoppingListsProvider.notifier);

    await notifier.toggleItemChecked(
      listId: 'general-list',
      itemId: 'baby-arugula',
    );

    final result = await notifier.completeShop('general-list');

    final updatedState = container.read(shoppingListsProvider).value!;
    final list = updatedState.getListById('general-list')!;

    expect(result, isNotNull);
    expect(result!.addedToPantryCount, 1);
    expect(result.skippedManualItems, ['Mock manual item']);
    expect(
      list.items.any((item) => item.id == 'baby-arugula'),
      isFalse,
    );
  });
  test('shoppingListsProvider creates shopping list', () async {
    //container used to read Riverpod providers in tests
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(shoppingListsProvider.future);

    final notifier = container.read(shoppingListsProvider.notifier);

    await notifier.createShoppingList(name: 'Weekend Braai');

    final updatedState = container.read(shoppingListsProvider).value!;
    final createdList = updatedState.lists.firstWhere(
      (list) => list.title == 'Weekend Braai',
    );

    expect(createdList.shoppingListId, 999);
    expect(createdList.section, 'OTHER LISTS');
    expect(createdList.items, isEmpty);
  });

  //deletes a whole shopping list from provider state
  test('shoppingListsProvider deletes shopping list', () async {
    //container used to read Riverpod providers in tests
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(shoppingListsProvider.future);

    final notifier = container.read(shoppingListsProvider.notifier);

    await notifier.deleteShoppingList('general-list');

    final updatedState = container.read(shoppingListsProvider).value!;

    expect(updatedState.getListById('general-list'), isNull);
    expect(
      updatedState.lists.any((list) => list.id == 'general-list'),
      isFalse,
    );
  });

  //renames a shopping list in provider state
  test('shoppingListsProvider updates shopping list name', () async {
    //container used to read Riverpod providers in tests
    final container = ProviderContainer(
      overrides: [
        shoppingListRepositoryProvider.overrideWithValue(
          _ApiShapedShoppingListRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(shoppingListsProvider.future);

    final notifier = container.read(shoppingListsProvider.notifier);

    await notifier.updateShoppingListName(
      listId: '1',
      name: 'Weekend Braai',
    );

    final updatedState = container.read(shoppingListsProvider).value!;
    final list = updatedState.getListById('1')!;

    expect(list.title, 'Weekend Braai');
    expect(list.status, 'ACTIVE');

    //items stay loaded because update endpoint only returns list
    expect(list.items, isNotEmpty);
  });
}
