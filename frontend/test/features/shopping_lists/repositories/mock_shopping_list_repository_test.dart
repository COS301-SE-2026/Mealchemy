import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/shopping_lists/repositories/mock_shopping_list_repository.dart';

void main() {
  //make sure it actually returns mock shopping list data
  test('MockShoppingListRepository returns shopping lists', () async {
    //mock repo instance (no API)
    final repository = MockShoppingListRepository();

    final lists = await repository.getShoppingLists();

    //expected mock data
    expect(lists, isNotEmpty);
    expect(lists.first.title, 'Weekly Groceries');
    expect(lists.any((list) => list.id == 'general-list'), isTrue);
  });

  //make sure one list can be found by id
  test('MockShoppingListRepository returns shopping list by id', () async {
    //mock repo instance (no API)
    final repository = MockShoppingListRepository();

    final list = await repository.getShoppingListById('general-list');

    //expected mock data
    expect(list, isNotNull);
    expect(list!.title, 'General List');
    expect(list.items, isNotEmpty);
  });

  //make sure unknown id returns null
  test('MockShoppingListRepository returns null for unknown id', () async {
    //mock repo instance (no API)
    final repository = MockShoppingListRepository();

    final list = await repository.getShoppingListById('unknown-list');

    //expected missing data
    expect(list, isNull);
  });
}