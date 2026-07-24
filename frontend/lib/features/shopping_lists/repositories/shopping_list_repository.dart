import '../models/shopping_list.dart';
import '../models/shopping_list_item.dart';

//contract for shopping list data source
abstract class ShoppingListRepository {
  //returns all shopping lists
  Future<List<ShoppingList>> getShoppingLists();

  //returns one shopping list by id
  Future<ShoppingList?> getShoppingListById(String id);
  //updates one item checked/purchased state
  Future<ShoppingListItem> updateItemPurchased({
    required String listId,
    required String itemId,
    required bool purchased,
  });
}
