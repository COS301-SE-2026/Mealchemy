import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/shopping_lists/providers/shopping_list_provider.dart';

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
}
