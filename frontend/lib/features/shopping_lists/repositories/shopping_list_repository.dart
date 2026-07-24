import '../models/shopping_list.dart';
import '../models/shopping_list_item.dart';
import '../models/complete_shop_result.dart';

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

  //adds a manual item to one shopping list
  Future<ShoppingListItem> addItemToShoppingList({
    required String listId,
    required String name,
    required String quantity,
    required String unit,
  });
  //moves purchased list items into pantry and removes them from this list
  Future<CompleteShopResult> completeShop(String listId);
}
