import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list_item.dart';

void main() {
  test('ShoppingListItem maps backend JSON into frontend model', () {
    final item = ShoppingListItem.fromJson({
      'item_id': 4,
      'shopping_list_id': 1,
      'ing_id': 12,
      'name': 'Greek Yogurt',
      'category': 'dairy',
      'quantity': 907.000,
      'unit': 'g',
      'purchased': true,
    });

    expect(item.id, '4');
    expect(item.itemId, 4);
    expect(item.shoppingListId, 1);
    expect(item.ingId, 12);
    expect(item.name, 'Greek Yogurt');
    expect(item.category, 'DAIRY');
    expect(item.quantity, '907 g');
    expect(item.unit, 'g');
    expect(item.checked, isTrue);
  });

  test('ShoppingListItem handles manual backend item without category', () {
    final item = ShoppingListItem.fromJson({
      'item_id': 5,
      'shopping_list_id': 1,
      'ing_id': null,
      'name': 'Fresh basil bunch',
      'category': null,
      'quantity': null,
      'unit': null,
      'purchased': false,
    });

    expect(item.id, '5');
    expect(item.ingId, isNull);
    expect(item.name, 'Fresh basil bunch');
    expect(item.category, 'MANUAL');
    expect(item.quantity, '-');
    expect(item.checked, isFalse);
  });

  test('ShoppingList maps backend JSON with items into frontend model', () {
    final list = ShoppingList.fromJson({
      'shopping_list_id': 1,
      'user_id': 3,
      'name': 'General List',
      'status': 'ACTIVE',
      'created_at': '2026-07-13T14:00:00Z',
      'items': [
        {
          'item_id': 1,
          'shopping_list_id': 1,
          'ing_id': null,
          'name': 'Heirloom Tomatoes',
          'category': null,
          'quantity': 8.000,
          'unit': 'g',
          'purchased': false,
        },
      ],
    });

    expect(list.id, '1');
    expect(list.shoppingListId, 1);
    expect(list.userId, 3);
    expect(list.title, 'General List');
    expect(list.status, 'ACTIVE');
    expect(list.section, 'OTHER LISTS');
    expect(list.iconType, 'list');
    expect(list.items, hasLength(1));
    expect(list.items.first.name, 'Heirloom Tomatoes');
  });
}
