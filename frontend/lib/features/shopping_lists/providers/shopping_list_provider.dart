import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../models/shopping_list.dart';
import '../repositories/mock_shopping_list_repository.dart';
import '../repositories/shopping_list_repository.dart';

//select mock/API
final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockShoppingListRepository();
  }

  //API repo will replace this once the backend endpoint exists
  return MockShoppingListRepository();
});

//state management provider
final shoppingListsProvider =
    AsyncNotifierProvider<ShoppingListsNotifier, ShoppingListsState>(
  ShoppingListsNotifier.new,
);

//current state of Shopping Lists flow. tracks lists and item checked states
class ShoppingListsState {
  const ShoppingListsState({
    required this.lists,
  });

  final List<ShoppingList> lists;

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

  ShoppingListsState copyWith({
    List<ShoppingList>? lists,
  }) {
    return ShoppingListsState(
      lists: lists ?? this.lists,
    );
  }
}

//handles shopping list interactions and updates state
class ShoppingListsNotifier extends AsyncNotifier<ShoppingListsState> {
  late final ShoppingListRepository _repository;

  //loads initial set of shopping lists
  @override
  Future<ShoppingListsState> build() async {
    _repository = ref.watch(shoppingListRepositoryProvider);

    final lists = await _repository.getShoppingLists();

    return ShoppingListsState(lists: lists);
  }

  //checks/unchecks an item in a shopping list
  void toggleItemChecked({
    required String listId,
    required String itemId,
  }) {
    final current = state.valueOrNull;
    if (current == null) return;

    final updatedLists = current.lists.map((list) {
      if (list.id != listId) return list;

      final updatedItems = list.items.map((item) {
        if (item.id != itemId) return item;

        return item.copyWith(checked: !item.checked);
      }).toList();

      return list.copyWith(items: updatedItems);
    }).toList();

    state = AsyncData(
      current.copyWith(lists: updatedLists),
    );
  }

  //resets shopping lists to original mock/API data
  Future<void> resetShoppingLists() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final lists = await _repository.getShoppingLists();
      return ShoppingListsState(lists: lists);
    });
  }
}