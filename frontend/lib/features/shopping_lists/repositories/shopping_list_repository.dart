import '../models/shopping_list.dart';
import '../models/shopping_list_item.dart';
import '../models/complete_shop_result.dart';

//contract for shopping list data source
abstract class ShoppingListRepository {
  //returns all shopping lists
  Future<List<ShoppingList>> getShoppingLists();

  //returns one shopping list by id
  Future<ShoppingList?> getShoppingListById(String id);

  //creates new shopping list for user
  Future<ShoppingList> createShoppingList({
    required String name,
    String status = 'ACTIVE',
  });

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

  //marks every item in one shopping list as purchased/checked
  Future<List<ShoppingListItem>> selectAllItems(String listId);

  //marks every item in one shopping list as not purchased/unchecked
  Future<List<ShoppingListItem>> deselectAllItems(String listId);
  //deletes several selected items from one shopping list
  Future<void> deleteShoppingListItems({
    required String listId,
    required List<int> itemIds,
  });
}
