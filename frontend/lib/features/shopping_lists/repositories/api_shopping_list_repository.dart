import 'package:dio/dio.dart';

import '../models/shopping_list.dart';

import 'shopping_list_repository.dart';
import '../models/shopping_list_item.dart';

//backend shopping list data source
class ApiShoppingListRepository implements ShoppingListRepository {
  ApiShoppingListRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<ShoppingList>> getShoppingLists() async {
    final response = await _dio.get<List<dynamic>>('/api/shopping-lists');
    final data = response.data ?? [];

    //overview endpoint returns lists without items, which is okay
    return data
        .map((item) => ShoppingList.fromJson(item as Map<String, dynamic>))
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
    required String name,
    required String quantity,
    required String unit,
  }) async {
    final cleanedName = name.trim();
    final cleanedQuantity = quantity.trim();
    final cleanedUnit = unit.trim();

    final parsedQuantity =
        cleanedQuantity.isEmpty ? null : num.tryParse(cleanedQuantity);

    if (cleanedName.isEmpty) {
      throw ArgumentError('Item name is required.');
    }

    if (cleanedQuantity.isNotEmpty && parsedQuantity == null) {
      throw ArgumentError('Quantity must be a valid number.');
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/shopping-lists/$listId/items',
      data: {
        'ing_id': null,
        'name': cleanedName,
        'quantity': parsedQuantity,
        'unit': cleanedUnit.isEmpty ? null : cleanedUnit,
      },
    );

    return ShoppingListItem.fromJson(response.data ?? {});
  }
}
