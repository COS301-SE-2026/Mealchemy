import 'package:dio/dio.dart';

import '../models/shopping_list.dart';

import 'shopping_list_repository.dart';
import '../models/shopping_list_item.dart';
import '../models/complete_shop_result.dart';

//backend shopping list data source
class ApiShoppingListRepository implements ShoppingListRepository {
  ApiShoppingListRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<ShoppingList>> getShoppingLists() async {
    final response = await _dio.get<List<dynamic>>('/api/shopping-lists');
    final data = response.data ?? [];
    return data
        .map((item) =>
            ShoppingList.fromOverviewJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ShoppingList?> getShoppingListById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/shopping-lists/$id',
    );

    final data = response.data;
    if (data == null) return null;

    return ShoppingList.fromJson(data);
  }

  @override
  Future<ShoppingList> createShoppingList({
    required String name,
    String status = 'ACTIVE',
  }) async {
    final cleanedName = name.trim();
    final cleanedStatus = status.trim().isEmpty ? 'ACTIVE' : status.trim();

    if (cleanedName.isEmpty) {
      throw ArgumentError('Shopping list name is required.');
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/shopping-lists',
      data: {
        'name': cleanedName,
        'status': cleanedStatus,
      },
    );

    return ShoppingList.fromJson(response.data ?? {});
  }

  @override
  Future<ShoppingListItem> updateItemPurchased({
    required String listId,
    required String itemId,
    required bool purchased,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/shopping-lists/$listId/items/$itemId/purchased',
      data: {
        'purchased': purchased,
      },
    );

    return ShoppingListItem.fromJson(response.data ?? {});
  }

  @override
  Future<ShoppingListItem> addItemToShoppingList({
    required String listId,
    int? ingId,
    String? name,
    required String quantity,
    required String unit,
  }) async {
    final cleanedName = name?.trim();
    final cleanedQuantity = quantity.trim();
    final cleanedUnit = unit.trim();

    final hasIngredientId = ingId != null;
    final hasCustomName = cleanedName != null && cleanedName.isNotEmpty;

    //backend accepts 1 identity: catalogue id or custom name
    if (hasIngredientId == hasCustomName) {
      throw ArgumentError(
        'Provide either an ingredient id or a custom item name, but not both.',
      );
    }

    final parsedQuantity =
        cleanedQuantity.isEmpty ? null : num.tryParse(cleanedQuantity);

    if (cleanedQuantity.isNotEmpty && parsedQuantity == null) {
      throw ArgumentError('Quantity must be a valid number.');
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/shopping-lists/$listId/items',
      data: {
        'ing_id': ingId,
        'name': hasCustomName ? cleanedName : null,
        'quantity': parsedQuantity,
        'unit': cleanedUnit.isEmpty ? null : cleanedUnit,
      },
    );

    return ShoppingListItem.fromJson(response.data ?? {});
  }

  @override
  Future<CompleteShopResult> completeShop(String listId) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/shopping-lists/$listId/complete-shop',
    );

    return CompleteShopResult.fromJson(response.data ?? {});
  }

  @override
  Future<List<ShoppingListItem>> selectAllItems(String listId) async {
    final response = await _dio.put<List<dynamic>>(
      '/api/shopping-lists/$listId/items/select-all',
    );

    final data = response.data ?? [];

    //backend sends updated items back
    return data
        .map((item) => ShoppingListItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ShoppingListItem>> deselectAllItems(String listId) async {
    final response = await _dio.put<List<dynamic>>(
      '/api/shopping-lists/$listId/items/deselect-all',
    );

    final data = response.data ?? [];

    //same idea as select all
    return data
        .map((item) => ShoppingListItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> deleteShoppingListItems({
    required String listId,
    required List<int> itemIds,
  }) async {
    if (itemIds.isEmpty) {
      throw ArgumentError('At least one item id is required.');
    }

    await _dio.post<void>(
      '/api/shopping-lists/$listId/items/batch-delete',
      data: {
        'item_ids': itemIds,
      },
    );
  }

  @override
  Future<void> deleteShoppingList(String listId) async {
    await _dio.delete<void>('/api/shopping-lists/$listId');
  }

  @override
  Future<ShoppingList> updateShoppingList({
    required String listId,
    required String name,
    String status = 'ACTIVE',
  }) async {
    final cleanedName = name.trim();
    if (cleanedName.isEmpty) {
      throw ArgumentError('Shopping list name is required.');
    }

    final response = await _dio.put<Map<String, dynamic>>(
      '/api/shopping-lists/$listId',
      data: {
        'name': cleanedName,
        'status': status,
      },
    );

    return ShoppingList.fromJson(response.data ?? {});
  }

  @override
  Future<ShoppingList> generateFromRecipe({
    required int recipeId,
    required String name,
    required bool includeAvailablePantryItems,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/shopping-lists/from-recipe/$recipeId',
      data: {
        'name': name.trim(),
        'include_available_pantry_items': includeAvailablePantryItems,
      },
    );
    return ShoppingList.fromJson(response.data ?? {});
  }
}
