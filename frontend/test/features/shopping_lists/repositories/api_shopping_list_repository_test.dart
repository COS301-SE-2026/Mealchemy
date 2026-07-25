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

          if (options.method == 'POST' &&
              options.path == '/api/shopping-lists/1/items') {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'item_id': 11,
                  'shopping_list_id': 1,
                  'ing_id': null,
                  'name': options.data['name'],
                  'category': null,
                  'quantity': options.data['quantity'],
                  'unit': options.data['unit'],
                  'purchased': false,
                },
              ),
            );
            return;
          }

          if (options.method == 'PUT' &&
              options.path == '/api/shopping-lists/1/complete-shop') {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'added_to_pantry_count': 2,
                  'skipped_manual_items': ['Fresh basil bunch'],
                  'shopping_list_deleted': false,
                },
              ),
            );
            return;
          }

          if (options.method == 'POST' &&
              options.path == '/api/shopping-lists') {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'shopping_list_id': 3,
                  'user_id': 3,
                  'name': options.data['name'],
                  'status': options.data['status'],
                  'created_at': '2026-07-13T14:20:00Z',
                },
              ),
            );
            return;
          }
          if (options.method == 'PUT' &&
              options.path == '/api/shopping-lists/1/items/select-all') {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: [
                  {
                    'item_id': 10,
                    'shopping_list_id': 1,
                    'ing_id': null,
                    'name': 'Greek Yogurt',
                    'category': null,
                    'quantity': 907.000,
                    'unit': 'g',
                    'purchased': true,
                  },
                  {
                    'item_id': 11,
                    'shopping_list_id': 1,
                    'ing_id': null,
                    'name': 'Fresh Basil',
                    'category': null,
                    'quantity': 1,
                    'unit': 'bunch',
                    'purchased': true,
                  },
                ],
              ),
            );
            return;
          }

          if (options.method == 'PUT' &&
              options.path == '/api/shopping-lists/1/items/deselect-all') {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: [
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
                  {
                    'item_id': 11,
                    'shopping_list_id': 1,
                    'ing_id': null,
                    'name': 'Fresh Basil',
                    'category': null,
                    'quantity': 1,
                    'unit': 'bunch',
                    'purchased': false,
                  },
                ],
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
  test('addItemToShoppingList posts manual item and maps response', () async {
    final item = await repository.addItemToShoppingList(
      listId: '1',
      name: 'Fresh Basil',
      quantity: '2',
      unit: 'bunches',
    );

    expect(lastRequest?.method, 'POST');
    expect(lastRequest?.path, '/api/shopping-lists/1/items');
    expect(lastRequest?.data['ing_id'], isNull);
    expect(lastRequest?.data['name'], 'Fresh Basil');
    expect(lastRequest?.data['quantity'], 2);
    expect(lastRequest?.data['unit'], 'bunches');

    expect(item.itemId, 11);
    expect(item.shoppingListId, 1);
    expect(item.name, 'Fresh Basil');
    expect(item.category, 'MANUAL');
    expect(item.quantity, '2 bunches');
    expect(item.checked, isFalse);
  });

  test('addItemToShoppingList rejects blank name before API call', () {
    expect(
      () => repository.addItemToShoppingList(
        listId: '1',
        name: '   ',
        quantity: '2',
        unit: 'bunches',
      ),
      throwsArgumentError,
    );
  });

  test('addItemToShoppingList rejects invalid quantity before API call', () {
    expect(
      () => repository.addItemToShoppingList(
        listId: '1',
        name: 'Fresh Basil',
        quantity: 'two',
        unit: 'bunches',
      ),
      throwsArgumentError,
    );
  });
  test('completeShop puts complete-shop endpoint and maps response', () async {
    final result = await repository.completeShop('1');

    expect(lastRequest?.method, 'PUT');
    expect(lastRequest?.path, '/api/shopping-lists/1/complete-shop');

    expect(result.addedToPantryCount, 2);
    expect(result.skippedManualItems, ['Fresh basil bunch']);
    expect(result.shoppingListDeleted, isFalse);
  });
  test('createShoppingList posts list metadata and maps response', () async {
    final list = await repository.createShoppingList(
      name: 'Weekend Braai',
    );

    expect(lastRequest?.method, 'POST');
    expect(lastRequest?.path, '/api/shopping-lists');
    expect(lastRequest?.data['name'], 'Weekend Braai');
    expect(lastRequest?.data['status'], 'ACTIVE');

    expect(list.id, '3');
    expect(list.shoppingListId, 3);
    expect(list.userId, 3);
    expect(list.title, 'Weekend Braai');
    expect(list.status, 'ACTIVE');
    expect(list.items, isEmpty);
  });

  test('createShoppingList rejects blank name before API call', () {
    expect(
      () => repository.createShoppingList(name: '   '),
      throwsArgumentError,
    );
  });
  test('selectAllItems puts select-all endpoint and maps updated items',
      () async {
    final items = await repository.selectAllItems('1');

    expect(lastRequest?.method, 'PUT');
    expect(lastRequest?.path, '/api/shopping-lists/1/items/select-all');

    expect(items, hasLength(2));
    expect(items.every((item) => item.checked), isTrue);
    expect(items.first.name, 'Greek Yogurt');
  });

  test('deselectAllItems puts deselect-all endpoint and maps updated items',
      () async {
    final items = await repository.deselectAllItems('1');

    expect(lastRequest?.method, 'PUT');
    expect(lastRequest?.path, '/api/shopping-lists/1/items/deselect-all');

    expect(items, hasLength(2));
    expect(items.every((item) => item.checked), isFalse);
    expect(items.last.name, 'Fresh Basil');
  });
}
