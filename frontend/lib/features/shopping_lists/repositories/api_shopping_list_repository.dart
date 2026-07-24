import 'package:dio/dio.dart';

import '../models/shopping_list.dart';

import 'shopping_list_repository.dart';

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
}
