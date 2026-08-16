import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../models/shopping_list.dart';
import '../repositories/mock_shopping_list_repository.dart';
import '../repositories/shopping_list_repository.dart';
import '../models/shopping_list_item.dart';
import '../../../core/providers/api_service_provider.dart';
import '../repositories/api_shopping_list_repository.dart';
import '../models/complete_shop_result.dart';

//select mock/API
final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  if (AppConfig.mockShoppinglist) {
    return MockShoppingListRepository();
  }

  return ApiShoppingListRepository(ref.read(dioProvider));
});

//state management provider
final shoppingListsProvider =
    AsyncNotifierProvider<ShoppingListsNotifier, ShoppingListsState>(
  ShoppingListsNotifier.new,
);

//current state of shopping list, tracks lists and item checked states
class ShoppingListsState {
  const ShoppingListsState({
    required this.lists,
    this.searchQuery = '',
  });

  final List<ShoppingList> lists;
  //search functionality
  final String searchQuery;

  //returns one list by id
  ShoppingList? getListById(String id) {
    for (final list in lists) {
      if (list.id == id) return list;
    }

    return null;
  }

  //groups lists by section label
  Map<String, List<ShoppingList>> get groupedLists {
    final grouped = <String, List<ShoppingList>>{};

    for (final list in lists) {
      grouped.putIfAbsent(list.section, () => []);
      grouped[list.section]!.add(list);
    }

    return grouped;
  }

  //returns lists filtered by search query
  List<ShoppingList> get filteredLists {
    final cleanedQuery = searchQuery.trim().toLowerCase();

    if (cleanedQuery.isEmpty) {
      return lists;
    }

    return lists.where((list) {
      return list.title.toLowerCase().contains(cleanedQuery) ||
          list.displaySubtitle.toLowerCase().contains(cleanedQuery);
    }).toList();
  }

  //groups filtered lists by section label
  Map<String, List<ShoppingList>> get groupedFilteredLists {
    final grouped = <String, List<ShoppingList>>{};

    for (final list in filteredLists) {
      grouped.putIfAbsent(list.section, () => []);
      grouped[list.section]!.add(list);
    }

    return grouped;
  }

  ShoppingListsState copyWith({
    List<ShoppingList>? lists,
    String? searchQuery,
  }) {
    return ShoppingListsState(
      lists: lists ?? this.lists,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

//handles shopping list interactions, updates state
class ShoppingListsNotifier extends AsyncNotifier<ShoppingListsState> {
  //read the active repo fresh each time so build re-running is harmless
  ShoppingListRepository get _repository =>
      ref.read(shoppingListRepositoryProvider);

  //loads initial set of shopping lists
  @override
  Future<ShoppingListsState> build() async {
    final lists = await _repository.getShoppingLists();

    return ShoppingListsState(lists: lists);
  }

  //creates new shopping list through the active repo
  Future<void> createShoppingList({
    required String name,
    String status = 'ACTIVE',
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final createdList = await _repository.createShoppingList(
      name: name,
      status: status,
    );

    state = AsyncData(
      current.copyWith(
        lists: [...current.lists, createdList],
      ),
    );
  }

  //deletes whole shopping list and removes it from local state
  Future<void> deleteShoppingList(String listId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    await _repository.deleteShoppingList(listId);

    final updatedLists =
        current.lists.where((list) => list.id != listId).toList();

    state = AsyncData(current.copyWith(lists: updatedLists));
  }

  //renames a shopping list and keeps local state in sync
  Future<void> updateShoppingListName({
    required String listId,
    required String name,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final existingList = current.getListById(listId);
    if (existingList == null) return;

    final updatedList = await _repository.updateShoppingList(
      listId: listId,
      name: name,
      status: existingList.status ?? 'ACTIVE',
    );

    final updatedLists = current.lists.map((list) {
      if (list.id != listId) return list;

      return updatedList.copyWith(
        //keep loaded items because the update endpoint returns list only
        items: list.items,
      );
    }).toList();

    state = AsyncData(current.copyWith(lists: updatedLists));
  }

  //checks/unchecks
  Future<void> toggleItemChecked({
    required String listId,
    required String itemId,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    ShoppingListItem? existingItem;
    for (final list in current.lists) {
      if (list.id != listId) continue;

      for (final item in list.items) {
        if (item.id == itemId) {
          existingItem = item;
          break;
        }
      }
    }

    if (existingItem == null) return;

    final updatedItem = await _repository.updateItemPurchased(
      listId: listId,
      itemId: itemId,
      purchased: !existingItem.checked,
    );

    final updatedLists = current.lists.map((list) {
      if (list.id != listId) return list;

      final updatedItems = list.items.map((item) {
        if (item.id != itemId) return item;

        //backend response
        return updatedItem;
      }).toList();

      return list.copyWith(items: updatedItems);
    }).toList();

    state = AsyncData(
      current.copyWith(lists: updatedLists),
    );
  }

//updates item's quantity and unit
  Future<void> updateShoppingListItem({
    required String listId,
    required String itemId,
    required String quantity,
    required String unit,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final list = current.getListById(listId);
    if (list == null) return;

    ShoppingListItem? existingItem;

    for (final item in list.items) {
      if (item.id == itemId) {
        existingItem = item;
        break;
      }
    }

    if (existingItem == null) return;

    final updatedItem = await _repository.updateShoppingListItem(
      listId: listId,
      itemId: itemId,
      ingId: existingItem.ingId,
      // Catalogue items are identified only by ing_id. Custom items use name.
      name: existingItem.ingId == null ? existingItem.name : null,
      quantity: quantity,
      unit: unit,
      purchased: existingItem.checked,
    );

    final updatedLists = current.lists.map((list) {
      if (list.id != listId) return list;

      final updatedItems = list.items.map((item) {
        if (item.id != itemId) return item;
        return updatedItem;
      }).toList();

      return list.copyWith(items: updatedItems);
    }).toList();

    state = AsyncData(
      current.copyWith(lists: updatedLists),
    );
  }

  //loads the full shopping list, including its items
  Future<void> loadShoppingListDetail(String listId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final fullList = await _repository.getShoppingListById(listId);
    if (fullList == null) return;

    final existingListFound = current.lists.any((list) => list.id == listId);

    final updatedLists = existingListFound
        ? current.lists.map((list) {
            if (list.id != listId) return list;
            return fullList;
          }).toList()
        : [...current.lists, fullList];

    state = AsyncData(current.copyWith(lists: updatedLists));
  }

  //marks every item in list as checked
  Future<void> selectAllItems(String listId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updatedItems = await _repository.selectAllItems(listId);

    final updatedLists = current.lists.map((list) {
      if (list.id != listId) return list;

      return list.copyWith(items: updatedItems);
    }).toList();

    state = AsyncData(current.copyWith(lists: updatedLists));
  }

  //clears all checked items in list
  Future<void> deselectAllItems(String listId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updatedItems = await _repository.deselectAllItems(listId);

    final updatedLists = current.lists.map((list) {
      if (list.id != listId) return list;

      return list.copyWith(items: updatedItems);
    }).toList();

    state = AsyncData(current.copyWith(lists: updatedLists));
  }

  //deletes every checked item from one shopping list
  Future<void> deleteSelectedItems(String listId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final list = current.getListById(listId);
    if (list == null) return;

    final selectedItems = list.items.where((item) => item.checked).toList();

    final selectedItemIds =
        selectedItems.map((item) => item.itemId).whereType<int>().toList();

    if (selectedItemIds.isEmpty) return;

    await _repository.deleteShoppingListItems(
      listId: listId,
      itemIds: selectedItemIds,
    );

    final selectedItemIdSet = selectedItemIds.toSet();

    final updatedLists = current.lists.map((list) {
      if (list.id != listId) return list;

      final remainingItems = list.items.where((item) {
        return item.itemId == null || !selectedItemIdSet.contains(item.itemId);
      }).toList();

      return list.copyWith(items: remainingItems);
    }).toList();

    state = AsyncData(current.copyWith(lists: updatedLists));
  }

  //adds catalogue ingredient or custom item through the active repo
  Future<void> addItemToList({
    required String listId,
    int? ingId,
    String? name,
    required String quantity,
    required String category,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final cleanedName = name?.trim();
    final cleanedQuantity = quantity.trim();
    final cleanedCategory = category.trim();
    final parsed = _splitQuantityAndUnit(cleanedQuantity);

    final createdItem = await _repository.addItemToShoppingList(
      listId: listId,
      ingId: ingId,
      name: cleanedName,
      quantity: parsed.quantity,
      unit: parsed.unit.isEmpty ? cleanedCategory : parsed.unit,
    );

    final updatedLists = current.lists.map((list) {
      if (list.id != listId) return list;

      //backend-created item
      return list.copyWith(
        items: [...list.items, createdItem],
      );
    }).toList();

    state = AsyncData(
      current.copyWith(lists: updatedLists),
    );
  }

  //moves checked shopping items to pantry through backend
  Future<CompleteShopResult?> completeShop(String listId) async {
    final current = state.valueOrNull;
    if (current == null) return null;

    final result = await _repository.completeShop(listId);

    final updatedLists = current.lists.map((list) {
      if (list.id != listId) return list;

      final remainingItems = list.items.where((item) => !item.checked).toList();

      return list.copyWith(items: remainingItems);
    }).toList();

    state = AsyncData(
      current.copyWith(
        //backend leaves an empty list in place
        lists: updatedLists,
      ),
    );

    return result;
  }

  //updates search query
  void updateSearchQuery(String query) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(searchQuery: query),
    );
  }

  //resets
  Future<void> resetShoppingLists() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final lists = await _repository.getShoppingLists();
      return ShoppingListsState(lists: lists);
    });
  }

  //generates a shopping list from a recipe's missing pantry items
  Future<ShoppingList?> generateFromRecipe({
    required int recipeId,
    required String recipeName,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return null;

    final createdList = await _repository.generateFromRecipe(
      recipeId: recipeId,
      name: recipeName,
      includeAvailablePantryItems: false, // false = only missing items
    );

    state = AsyncData(
      current.copyWith(lists: [...current.lists, createdList]),
    );

    return createdList;
  }
}

//helper
({String quantity, String unit}) _splitQuantityAndUnit(String rawQuantity) {
  final cleaned = rawQuantity.trim();
  if (cleaned.isEmpty) {
    return (quantity: '', unit: '');
  }

  final parts = cleaned.split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return (quantity: parts.first, unit: '');
  }

  return (
    quantity: parts.first,
    unit: parts.sublist(1).join(' '),
  );
}
