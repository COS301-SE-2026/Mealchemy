import 'package:drift/drift.dart';

import '../../shopping_lists/models/shopping_list.dart';
import '../../shopping_lists/models/shopping_list_item.dart';
import 'offline_cache_database.dart';
import 'offline_cache_store.dart';

class ShoppingListCacheStore {
  ShoppingListCacheStore(this._database, this._metadata);

  final OfflineCacheDatabase _database;
  final OfflineCacheStore _metadata;

  Future<List<ShoppingList>> readLists({required int viewerUserId}) async {
    final rows = await (_database.select(_database.cachedShoppingListRows)
          ..where((row) => row.viewerUserId.equals(viewerUserId))
          ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
        .get();
    return rows.map(_summaryFromRow).toList();
  }

  Future<ShoppingList?> readCompleteList({
    required int viewerUserId,
    required String listId,
  }) async {
    final listRow = await (_database.select(_database.cachedShoppingListRows)
          ..where(
            (row) =>
                row.viewerUserId.equals(viewerUserId) &
                row.listId.equals(listId) &
                row.isComplete.equals(true),
          ))
        .getSingleOrNull();
    if (listRow == null) return null;

    final itemRows =
        await (_database.select(_database.cachedShoppingListItemRows)
              ..where(
                (row) =>
                    row.viewerUserId.equals(viewerUserId) &
                    row.listId.equals(listId),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.lineIndex)]))
            .get();
    return _summaryFromRow(listRow).copyWith(
      items: itemRows
          .map(
            (row) => ShoppingListItem(
              id: row.itemKey,
              itemId: row.itemId,
              shoppingListId: row.shoppingListId,
              ingId: row.ingId,
              name: row.name,
              quantity: row.quantity,
              category: row.category,
              unit: row.unit,
              checked: row.checked,
            ),
          )
          .toList(),
    );
  }

  Future<void> replaceSummariesFromCompleteFetch({
    required int viewerUserId,
    required List<ShoppingList> lists,
    required DateTime syncedAt,
  }) {
    return _database.transaction(() async {
      final previous = await (_database.select(_database.cachedShoppingListRows)
            ..where((row) => row.viewerUserId.equals(viewerUserId)))
          .get();
      final incomingIds = lists.map((list) => list.id).toSet();
      final removedIds = previous
          .map((list) => list.listId)
          .where((id) => !incomingIds.contains(id))
          .toSet();
      if (removedIds.isNotEmpty) {
        await (_database.delete(_database.cachedShoppingListItemRows)
              ..where(
                (row) =>
                    row.viewerUserId.equals(viewerUserId) &
                    row.listId.isIn(removedIds),
              ))
            .go();
        await (_database.delete(_database.cachedShoppingListRows)
              ..where(
                (row) =>
                    row.viewerUserId.equals(viewerUserId) &
                    row.listId.isIn(removedIds),
              ))
            .go();
      }

      for (final list in lists) {
        final existing =
            previous.where((row) => row.listId == list.id).firstOrNull;
        await _database
            .into(_database.cachedShoppingListRows)
            .insertOnConflictUpdate(
              _listCompanion(
                viewerUserId: viewerUserId,
                list: list,
                isComplete: existing?.isComplete ?? false,
              ),
            );
      }
      await _metadata.writeSyncMetadata(
        viewerUserId: viewerUserId,
        collection: CacheCollection.shoppingLists,
        scopeId: CacheScope.all,
        syncedAt: syncedAt,
      );
    });
  }

  Future<void> storeCompleteList({
    required int viewerUserId,
    required ShoppingList list,
    required DateTime syncedAt,
  }) {
    return _database.transaction(() async {
      await _database
          .into(_database.cachedShoppingListRows)
          .insertOnConflictUpdate(
            _listCompanion(
              viewerUserId: viewerUserId,
              list: list,
              isComplete: true,
            ),
          );
      await (_database.delete(_database.cachedShoppingListItemRows)
            ..where(
              (row) =>
                  row.viewerUserId.equals(viewerUserId) &
                  row.listId.equals(list.id),
            ))
          .go();
      await _database.batch((batch) {
        batch.insertAll(
          _database.cachedShoppingListItemRows,
          [
            for (var index = 0; index < list.items.length; index++)
              CachedShoppingListItemRowsCompanion.insert(
                viewerUserId: viewerUserId,
                listId: list.id,
                itemKey: list.items[index].id,
                itemId: Value(list.items[index].itemId),
                shoppingListId: Value(list.items[index].shoppingListId),
                ingId: Value(list.items[index].ingId),
                name: list.items[index].name,
                quantity: list.items[index].quantity,
                category: list.items[index].category,
                unit: Value(list.items[index].unit),
                checked: list.items[index].checked,
                lineIndex: index,
              ),
          ],
        );
      });
      await _metadata.writeSyncMetadata(
        viewerUserId: viewerUserId,
        collection: CacheCollection.shoppingList,
        scopeId: list.id,
        syncedAt: syncedAt,
      );
    });
  }

  CachedShoppingListRowsCompanion _listCompanion({
    required int viewerUserId,
    required ShoppingList list,
    required bool isComplete,
  }) {
    return CachedShoppingListRowsCompanion.insert(
      viewerUserId: viewerUserId,
      listId: list.id,
      shoppingListId: Value(list.shoppingListId),
      serverUserId: Value(list.userId),
      numItems: Value(list.numItems),
      title: list.title,
      subtitle: list.subtitle,
      section: list.section,
      iconType: list.iconType,
      status: Value(list.status),
      createdAt: Value(list.createdAt),
      imageUrl: Value(list.imageUrl),
      favourite: list.favourite,
      isComplete: Value(isComplete),
    );
  }

  ShoppingList _summaryFromRow(CachedShoppingListRow row) {
    return ShoppingList(
      id: row.listId,
      shoppingListId: row.shoppingListId,
      userId: row.serverUserId,
      numItems: row.numItems,
      title: row.title,
      subtitle: row.subtitle,
      section: row.section,
      iconType: row.iconType,
      status: row.status,
      createdAt: row.createdAt,
      imageUrl: row.imageUrl,
      favourite: row.favourite,
      items: const [],
    );
  }
}
