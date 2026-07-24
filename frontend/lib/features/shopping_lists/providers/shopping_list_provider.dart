import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../models/shopping_list.dart';
import '../repositories/mock_shopping_list_repository.dart';
import '../repositories/shopping_list_repository.dart';
import '../models/shopping_list_item.dart';
import '../../../core/providers/api_service_provider.dart';
import '../repositories/api_shopping_list_repository.dart';

//select mock/API
final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  if (AppConfig.useMockData) {
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
  late final ShoppingListRepository _repository;

  //loads initial set of shopping lists
  @override
  Future<ShoppingListsState> build() async {
    _repository = ref.watch(shoppingListRepositoryProvider);

    final lists = await _repository.getShoppingLists();

    return ShoppingListsState(lists: lists);
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

  //adds new item
  void addItemToList({
    required String listId,
    required String name,
    required String quantity,
    required String category,
  }) {
    final current = state.valueOrNull;
    final cleanedName = name.trim();
    final cleanedQuantity = quantity.trim();
    final cleanedCategory = category.trim().toUpperCase();

    if (current == null || cleanedName.isEmpty || cleanedCategory.isEmpty) {
      return;
    }

    final newItem = ShoppingListItem(
      id: cleanedName.toLowerCase().replaceAll(' ', '-'),
      name: cleanedName,
      quantity: cleanedQuantity.isEmpty ? '-' : cleanedQuantity,
      category: cleanedCategory,
    );

    final updatedLists = current.lists.map((list) {
      if (list.id != listId) return list;

      return list.copyWith(
        items: [...list.items, newItem],
      );
    }).toList();

    state = AsyncData(
      current.copyWith(lists: updatedLists),
    );
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
}
