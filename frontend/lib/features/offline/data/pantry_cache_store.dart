import 'package:drift/drift.dart';

import '../../pantry/models/pantry_ingredient.dart';
import '../../pantry/widgets/pantry_item_card.dart';
import 'offline_cache_database.dart';
import 'offline_cache_store.dart';

class PantryCacheStore {
  PantryCacheStore(this._database, this._metadata);

  final OfflineCacheDatabase _database;
  final OfflineCacheStore _metadata;

  Future<List<PantryIngredient>> readIngredients({
    required int viewerUserId,
  }) async {
    final rows = await (_database.select(_database.cachedPantryIngredientRows)
          ..where((row) => row.viewerUserId.equals(viewerUserId))
          ..orderBy([(row) => OrderingTerm.asc(row.name)]))
        .get();
    await _metadata.markSyncMetadataAccess(
      viewerUserId: viewerUserId,
      collection: CacheCollection.pantry,
      scopeId: CacheScope.all,
    );
    return rows
        .map(
          (row) => PantryIngredient(
            pIngredientId: row.pantryIngredientId,
            ingId: row.ingId,
            name: row.name,
            details: row.details,
            category: row.category,
            status: PantryItemStatus.values.firstWhere(
              (status) => status.name == row.status,
              orElse: () => PantryItemStatus.fresh,
            ),
            quantity: row.quantity,
            unit: row.unit,
          ),
        )
        .toList();
  }

  Future<void> replaceFromCompleteFetch({
    required int viewerUserId,
    required List<PantryIngredient> ingredients,
    required DateTime syncedAt,
  }) {
    return _database.transaction(() async {
      await (_database.delete(_database.cachedPantryIngredientRows)
            ..where((row) => row.viewerUserId.equals(viewerUserId)))
          .go();
      await _database.batch((batch) {
        batch.insertAll(
          _database.cachedPantryIngredientRows,
          [
            for (var index = 0; index < ingredients.length; index++)
              CachedPantryIngredientRowsCompanion.insert(
                viewerUserId: viewerUserId,
                rowKey: _rowKey(ingredients[index], index),
                pantryIngredientId: Value(ingredients[index].pIngredientId),
                ingId: Value(ingredients[index].ingId),
                name: ingredients[index].name,
                details: ingredients[index].details,
                category: ingredients[index].category,
                status: ingredients[index].status.name,
                quantity: Value(ingredients[index].quantity),
                unit: Value(ingredients[index].unit),
              ),
          ],
        );
      });
      await _metadata.writeSyncMetadata(
        viewerUserId: viewerUserId,
        collection: CacheCollection.pantry,
        scopeId: CacheScope.all,
        syncedAt: syncedAt,
      );
    });
  }

  String _rowKey(PantryIngredient ingredient, int index) {
    final pantryId = ingredient.pIngredientId;
    if (pantryId != null) return 'pantry:$pantryId';
    final ingredientId = ingredient.ingId;
    if (ingredientId != null) return 'ingredient:$ingredientId:$index';
    return 'row:$index';
  }
}
