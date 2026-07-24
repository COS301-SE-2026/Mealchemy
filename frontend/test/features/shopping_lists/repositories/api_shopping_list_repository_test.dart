import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/shopping_lists/repositories/api_shopping_list_repository.dart';

void main() {
  late ApiShoppingListRepository repository;
  late RequestOptions? lastRequest;

  setUp(() {
    final dio = Dio();
    lastRequest = null;

    //fake backend - tests fast and offline
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          lastRequest = options;

          if (options.method == 'PATCH' &&
              options.path == '/api/shopping-lists/1/items/10/purchased') {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'item_id': 10,
                  'shopping_list_id': 1,
                  'ing_id': null,
                  'name': 'Greek Yogurt',
                  'category': null,
                  'quantity': 907.000,
                  'unit': 'g',
                  'purchased': options.data['purchased'],
                },
              ),
            );
            return;
          }
          if (options.path == '/api/shopping-lists/1') {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'shopping_list_id': 1,
                  'user_id': 3,
                  'name': 'General List',
                  'status': 'ACTIVE',
                  'created_at': '2026-07-13T14:00:00Z',
                  'items': [
                    {
                      'item_id': 10,
                      'shopping_list_id': 1,
                      'ing_id': null,
                      'name': 'Greek Yogurt',
                      'category': null,
                      'quantity': 907.000,
                      'unit': 'g',
                      'purchased': false,
                    },
                  ],
                },
              ),
            );
            return;
          }

          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: [
                {
                  'shopping_list_id': 1,
                  'user_id': 3,
                  'name': 'General List',
                  'status': 'ACTIVE',
                  'created_at': '2026-07-13T14:00:00Z',
                },
                {
                  'shopping_list_id': 2,
                  'user_id': 3,
                  'name': 'Weekly Groceries',
                  'status': 'ACTIVE',
                  'created_at': '2026-07-13T14:10:00Z',
                },
              ],
            ),
          );
        },
      ),
    );

    repository = ApiShoppingListRepository(dio);
  });

  test('getShoppingLists maps backend list overview response', () async {
    final lists = await repository.getShoppingLists();

    expect(lastRequest?.path, '/api/shopping-lists');
    expect(lists, hasLength(2));

    expect(lists.first.id, '1');
    expect(lists.first.shoppingListId, 1);
    expect(lists.first.userId, 3);
    expect(lists.first.title, 'General List');
    expect(lists.first.status, 'ACTIVE');
    expect(lists.first.items, isEmpty);
  });

  test('getShoppingListById maps backend list detail response', () async {
    final list = await repository.getShoppingListById('1');

    expect(lastRequest?.path, '/api/shopping-lists/1');
    expect(list, isNotNull);
    expect(list!.shoppingListId, 1);
    expect(list.title, 'General List');
    expect(list.items, hasLength(1));

    final item = list.items.first;
    expect(item.itemId, 10);
    expect(item.shoppingListId, 1);
    expect(item.name, 'Greek Yogurt');
    expect(item.category, 'MANUAL');
    expect(item.quantity, '907 g');
    expect(item.checked, isFalse);
  });
  test('updateItemPurchased patches purchased state and maps response',
      () async {
    final item = await repository.updateItemPurchased(
      listId: '1',
      itemId: '10',
      purchased: true,
    );

    expect(lastRequest?.method, 'PATCH');
    expect(lastRequest?.path, '/api/shopping-lists/1/items/10/purchased');
    expect(lastRequest?.data['purchased'], true);

    expect(item.itemId, 10);
    expect(item.shoppingListId, 1);
    expect(item.name, 'Greek Yogurt');
    expect(item.checked, isTrue);
  });
}
