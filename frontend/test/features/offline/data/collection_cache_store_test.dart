import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/offline/data/offline_cache_database.dart';
import 'package:mealchemy/features/offline/data/offline_cache_store.dart';
import 'package:mealchemy/features/offline/data/pantry_cache_store.dart';
import 'package:mealchemy/features/offline/data/shopping_list_cache_store.dart';
import 'package:mealchemy/features/pantry/models/pantry_ingredient.dart';
import 'package:mealchemy/features/pantry/widgets/pantry_item_card.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list.dart';
import 'package:mealchemy/features/shopping_lists/models/shopping_list_item.dart';

void main() {
  late OfflineCacheDatabase database;
  late PantryCacheStore pantryCache;
  late ShoppingListCacheStore shoppingCache;

  setUp(() {
    database = OfflineCacheDatabase(NativeDatabase.memory());
    final metadata = OfflineCacheStore(database);
    pantryCache = PantryCacheStore(database, metadata);
    shoppingCache = ShoppingListCacheStore(database, metadata);
  });

  tearDown(() => database.close());

  test('pantry rows with the same server id are isolated by viewer', () async {
    final syncedAt = DateTime.utc(2026, 8, 30);
    await pantryCache.replaceFromCompleteFetch(
      viewerUserId: 1,
      ingredients: [_pantryIngredient('User one salt')],
      syncedAt: syncedAt,
    );
    await pantryCache.replaceFromCompleteFetch(
      viewerUserId: 2,
      ingredients: [_pantryIngredient('User two salt')],
      syncedAt: syncedAt,
    );

    expect(
      (await pantryCache.readIngredients(viewerUserId: 1)).single.name,
      'User one salt',
    );
    expect(
      (await pantryCache.readIngredients(viewerUserId: 2)).single.name,
      'User two salt',
    );
  });

  test('summary refresh preserves a complete shopping-list aggregate',
      () async {
    final syncedAt = DateTime.utc(2026, 8, 30);
    await shoppingCache.storeCompleteList(
      viewerUserId: 1,
      list: _completeList('Original title'),
      syncedAt: syncedAt,
    );

    await shoppingCache.replaceSummariesFromCompleteFetch(
      viewerUserId: 1,
      lists: [_listSummary('Updated title')],
      syncedAt: syncedAt.add(const Duration(minutes: 1)),
    );

    final cached = await shoppingCache.readCompleteList(
      viewerUserId: 1,
      listId: '10',
    );
    expect(cached?.title, 'Updated title');
    expect(cached?.items.single.name, 'Milk');
  });

  test('complete list reconciliation does not remove another viewer data',
      () async {
    final syncedAt = DateTime.utc(2026, 8, 30);
    await shoppingCache.replaceSummariesFromCompleteFetch(
      viewerUserId: 1,
      lists: [_listSummary('User one')],
      syncedAt: syncedAt,
    );
    await shoppingCache.replaceSummariesFromCompleteFetch(
      viewerUserId: 2,
      lists: [_listSummary('User two')],
      syncedAt: syncedAt,
    );

    await shoppingCache.replaceSummariesFromCompleteFetch(
      viewerUserId: 1,
      lists: const [],
      syncedAt: syncedAt.add(const Duration(minutes: 1)),
    );

    expect(await shoppingCache.readLists(viewerUserId: 1), isEmpty);
    expect(
      (await shoppingCache.readLists(viewerUserId: 2)).single.title,
      'User two',
    );
  });
}

PantryIngredient _pantryIngredient(String name) => PantryIngredient(
      pIngredientId: 5,
      ingId: 8,
      name: name,
      details: '1kg - Pantry',
      category: 'Other',
      status: PantryItemStatus.fresh,
      quantity: '1',
      unit: 'kg',
    );

ShoppingList _listSummary(String title) => ShoppingList(
      id: '10',
      shoppingListId: 10,
      userId: 99,
      numItems: 1,
      title: title,
      subtitle: '1 item',
      section: 'OTHER LISTS',
      iconType: 'list',
      items: const [],
      createdAt: DateTime.utc(2026, 8, 30),
    );

ShoppingList _completeList(String title) => _listSummary(title).copyWith(
      items: const [
        ShoppingListItem(
          id: '100',
          itemId: 100,
          shoppingListId: 10,
          ingId: 8,
          name: 'Milk',
          quantity: '1 l',
          category: 'DAIRY',
          unit: 'l',
        ),
      ],
    );
