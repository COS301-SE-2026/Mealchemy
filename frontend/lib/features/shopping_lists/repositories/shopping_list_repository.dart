import '../models/shopping_list.dart';

//contract for shopping list data source
abstract class ShoppingListRepository {
  //returns all shopping lists
  Future<List<ShoppingList>> getShoppingLists();

  //returns one shopping list by id
  Future<ShoppingList?> getShoppingListById(String id);
}