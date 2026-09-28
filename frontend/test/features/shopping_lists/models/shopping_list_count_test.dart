import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list.dart';

void main() {
  test('creation response preserves count when items are not included', () {
    final list = ShoppingList.fromJson({
      'shopping_list_id': 41,
      'user_id': 7,
      'name': 'Pasta ingredients',
      'status': 'ACTIVE',
      'num_items': 12,
    });

    expect(list.id, '41');
    expect(list.items, isEmpty);
    expect(list.itemCount, 12);
    expect(list.displaySubtitle, '12 items added by you');
  });

  test('an explicitly empty items array represents an empty list', () {
    final list = ShoppingList.fromJson({
      'shopping_list_id': 41,
      'name': 'Pasta ingredients',
      'num_items': 12,
      'items': <Map<String, dynamic>>[],
    });

    expect(list.items, isEmpty);
    expect(list.itemCount, 0);
  });

  test('response without items or a count defaults to zero', () {
    final list = ShoppingList.fromJson({
      'shopping_list_id': 41,
      'name': 'New list',
    });

    expect(list.itemCount, 0);
  });
}
