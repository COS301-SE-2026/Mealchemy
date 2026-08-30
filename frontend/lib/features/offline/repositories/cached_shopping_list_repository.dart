import '../../shopping_lists/models/complete_shop_result.dart';
import '../../shopping_lists/models/shopping_list.dart';
import '../../shopping_lists/models/shopping_list_item.dart';
import '../../shopping_lists/repositories/shopping_list_repository.dart';
import '../data/offline_cache_policy.dart';
import '../data/shopping_list_cache_store.dart';

class CachedShoppingListRepository implements ShoppingListRepository {
  CachedShoppingListRepository({
    required ShoppingListRepository remote,
    required ShoppingListCacheStore cache,
    required int viewerUserId,
  })  : _remote = remote,
        _cache = cache,
        _viewerUserId = viewerUserId;

  final ShoppingListRepository _remote;
  final ShoppingListCacheStore _cache;
  final int _viewerUserId;

  @override
  Future<List<ShoppingList>> getShoppingLists() async {
    try {
      final lists = await _remote.getShoppingLists();
      await _cache.replaceSummariesFromCompleteFetch(
        viewerUserId: _viewerUserId,
        lists: lists,
        syncedAt: DateTime.now().toUtc(),
      );
      return lists;
    } catch (error) {
      if (!isOfflineTransportFailure(error)) rethrow;
      return _cache.readLists(viewerUserId: _viewerUserId);
    }
  }

  @override
  Future<ShoppingList?> getShoppingListById(String id) async {
    try {
      final list = await _remote.getShoppingListById(id);
      if (list != null) {
        await _cache.storeCompleteList(
          viewerUserId: _viewerUserId,
          list: list,
          syncedAt: DateTime.now().toUtc(),
        );
      }
      return list;
    } catch (error) {
      if (!isOfflineTransportFailure(error)) rethrow;
      return _cache.readCompleteList(
        viewerUserId: _viewerUserId,
        listId: id,
      );
    }
  }

  @override
  Future<ShoppingList> createShoppingList({
    required String name,
    String status = 'ACTIVE',
  }) =>
      _remote.createShoppingList(name: name, status: status);

  @override
  Future<ShoppingListItem> updateItemPurchased({
    required String listId,
    required String itemId,
    required bool purchased,
  }) =>
      _remote.updateItemPurchased(
        listId: listId,
        itemId: itemId,
        purchased: purchased,
      );

  @override
  Future<ShoppingListItem> updateShoppingListItem({
    required String listId,
    required String itemId,
    int? ingId,
    String? name,
    required String quantity,
    required String unit,
    required bool purchased,
  }) =>
      _remote.updateShoppingListItem(
        listId: listId,
        itemId: itemId,
        ingId: ingId,
        name: name,
        quantity: quantity,
        unit: unit,
        purchased: purchased,
      );

  @override
  Future<ShoppingListItem> addItemToShoppingList({
    required String listId,
    int? ingId,
    String? name,
    required String quantity,
    required String unit,
  }) =>
      _remote.addItemToShoppingList(
        listId: listId,
        ingId: ingId,
        name: name,
        quantity: quantity,
        unit: unit,
      );

  @override
  Future<CompleteShopResult> completeShop(String listId) =>
      _remote.completeShop(listId);

  @override
  Future<List<ShoppingListItem>> selectAllItems(String listId) =>
      _remote.selectAllItems(listId);

  @override
  Future<List<ShoppingListItem>> deselectAllItems(String listId) =>
      _remote.deselectAllItems(listId);

  @override
  Future<void> deleteShoppingListItems({
    required String listId,
    required List<int> itemIds,
  }) =>
      _remote.deleteShoppingListItems(listId: listId, itemIds: itemIds);

  @override
  Future<void> deleteShoppingList(String listId) =>
      _remote.deleteShoppingList(listId);

  @override
  Future<ShoppingList> updateShoppingList({
    required String listId,
    required String name,
    String status = 'ACTIVE',
  }) =>
      _remote.updateShoppingList(
        listId: listId,
        name: name,
        status: status,
      );

  @override
  Future<ShoppingList> generateFromRecipe({
    required int recipeId,
    required String name,
    required bool includeAvailablePantryItems,
  }) =>
      _remote.generateFromRecipe(
        recipeId: recipeId,
        name: name,
        includeAvailablePantryItems: includeAvailablePantryItems,
      );
}
