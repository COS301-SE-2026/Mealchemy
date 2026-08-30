import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/offline/data/offline_cache_database.dart';
import 'package:mealchemy/features/offline/data/offline_cache_store.dart';
import 'package:mealchemy/features/offline/data/shopping_list_cache_store.dart';
import 'package:mealchemy/features/offline/repositories/cached_shopping_list_repository.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list_item.dart';
import 'package:mealchemy/features/shopping_lists/repositories/mock_shopping_list_repository.dart';

void main() {
  late OfflineCacheDatabase database;
  late ShoppingListCacheStore cache;

  setUp(() {
    database = OfflineCacheDatabase(NativeDatabase.memory());
    cache = ShoppingListCacheStore(database, OfflineCacheStore(database));
  });

  tearDown(() => database.close());

  test('successful summary fetch refreshes only the viewer cache', () async {
    final remote = _ShoppingRemote(list: _list('Fresh API list'));
    final repository = CachedShoppingListRepository(
      remote: remote,
      cache: cache,
      viewerUserId: 11,
    );

    final result = await repository.getShoppingLists();

    expect(result.single.title, 'Fresh API list');
    expect(
      (await cache.readLists(viewerUserId: 11)).single.title,
      'Fresh API list',
    );
    expect(await cache.readLists(viewerUserId: 12), isEmpty);
  });

  test('transport summary failure returns cached lists', () async {
    await cache.replaceSummariesFromCompleteFetch(
      viewerUserId: 11,
      lists: [_list('Cached list')],
      syncedAt: DateTime.now().toUtc(),
    );
    final repository = CachedShoppingListRepository(
      remote: _ShoppingRemote(
        list: _list('Remote'),
        listError: _connectionError(),
      ),
      cache: cache,
      viewerUserId: 11,
    );

    expect((await repository.getShoppingLists()).single.title, 'Cached list');
  });

  test('successful detail fetch stores a complete aggregate', () async {
    final repository = CachedShoppingListRepository(
      remote: _ShoppingRemote(list: _list('Fresh detail', complete: true)),
      cache: cache,
      viewerUserId: 11,
    );

    final result = await repository.getShoppingListById('10');
    final cached = await cache.readCompleteList(
      viewerUserId: 11,
      listId: '10',
    );

    expect(result?.items.single.name, 'Milk');
    expect(cached?.title, 'Fresh detail');
    expect(cached?.items.single.name, 'Milk');
  });

  test('transport detail failure returns the complete cached aggregate',
      () async {
    await cache.storeCompleteList(
      viewerUserId: 11,
      list: _list('Cached detail', complete: true),
      syncedAt: DateTime.now().toUtc(),
    );
    final repository = CachedShoppingListRepository(
      remote: _ShoppingRemote(
        list: _list('Remote'),
        detailError: _connectionError(),
      ),
      cache: cache,
      viewerUserId: 11,
    );

    final result = await repository.getShoppingListById('10');

    expect(result?.title, 'Cached detail');
    expect(result?.items.single.name, 'Milk');
  });

  test('HTTP errors propagate instead of returning stale lists', () async {
    final error = _httpError(403);
    final repository = CachedShoppingListRepository(
      remote: _ShoppingRemote(list: _list('Remote'), listError: error),
      cache: cache,
      viewerUserId: 11,
    );

    await expectLater(repository.getShoppingLists(), throwsA(same(error)));
  });

  test('forwards every mutation to the remote repository', () async {
    final repository = CachedShoppingListRepository(
      remote: MockShoppingListRepository(),
      cache: cache,
      viewerUserId: 11,
    );

    expect((await repository.createShoppingList(name: 'Weekend')).title,
        'Weekend');
    expect(
      (await repository.updateItemPurchased(
        listId: 'general-list',
        itemId: 'heirloom-tomatoes',
        purchased: true,
      ))
          .checked,
      isTrue,
    );
    expect(
      (await repository.updateShoppingListItem(
        listId: 'general-list',
        itemId: 'heirloom-tomatoes',
        name: 'Tomatoes',
        quantity: '2',
        unit: 'kg',
        purchased: false,
      ))
          .unit,
      'kg',
    );
    expect(
      (await repository.addItemToShoppingList(
        listId: 'general-list',
        name: 'Bread',
        quantity: '1',
        unit: 'pcs',
      ))
          .name,
      'Bread',
    );
    expect(
        (await repository.completeShop('general-list')).addedToPantryCount, 1);
    expect(await repository.selectAllItems('general-list'), isNotEmpty);
    expect(await repository.deselectAllItems('general-list'), isNotEmpty);
    await repository.deleteShoppingListItems(
      listId: 'general-list',
      itemIds: const [201],
    );
    await repository.deleteShoppingList('general-list');
    expect(
      (await repository.updateShoppingList(
        listId: 'general-list',
        name: 'Renamed',
      ))
          .title,
      'Renamed',
    );
    expect(
      (await repository.generateFromRecipe(
        recipeId: 7,
        name: 'Generated',
        includeAvailablePantryItems: true,
      ))
          .title,
      'Generated',
    );
  });
}

ShoppingList _list(String title, {bool complete = false}) => ShoppingList(
      id: '10',
      shoppingListId: 10,
      userId: 99,
      numItems: complete ? 1 : 0,
      title: title,
      subtitle: complete ? '1 item' : '0 items',
      section: 'OTHER LISTS',
      iconType: 'list',
      createdAt: DateTime.utc(2026, 8, 30),
      items: complete
          ? const [
              ShoppingListItem(
                id: '100',
                itemId: 100,
                shoppingListId: 10,
                ingId: 8,
                name: 'Milk',
                quantity: '1 L',
                category: 'DAIRY',
                unit: 'L',
              ),
            ]
          : const [],
    );

class _ShoppingRemote extends MockShoppingListRepository {
  _ShoppingRemote({
    required this.list,
    this.listError,
    this.detailError,
  });

  final ShoppingList list;
  final Object? listError;
  final Object? detailError;

  @override
  Future<List<ShoppingList>> getShoppingLists() async {
    if (listError case final error?) throw error;
    return [list.copyWith(items: const [])];
  }

  @override
  Future<ShoppingList?> getShoppingListById(String id) async {
    if (detailError case final error?) throw error;
    return list;
  }
}

DioException _connectionError() => DioException(
      requestOptions: RequestOptions(path: '/shopping-lists'),
      type: DioExceptionType.connectionError,
    );

DioException _httpError(int statusCode) => DioException.badResponse(
      statusCode: statusCode,
      requestOptions: RequestOptions(path: '/shopping-lists'),
      response: Response<void>(
        requestOptions: RequestOptions(path: '/shopping-lists'),
        statusCode: statusCode,
      ),
    );
