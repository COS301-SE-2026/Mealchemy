import '../models/shopping_list.dart';
import '../models/shopping_list_item.dart';
import 'shopping_list_repository.dart';
import '../models/complete_shop_result.dart';

//temporary mock data for shopping lists
class MockShoppingListRepository implements ShoppingListRepository {
  final List<ShoppingList> _lists = const [
    ShoppingList(
      id: 'weekly-groceries',
      title: 'Weekly Groceries',
      subtitle: '8 items',
      section: 'FAVORITES',
      iconType: 'star',
      favourite: true,
      items: [
        ShoppingListItem(
          id: 'milk',
          name: 'Organic Milk',
          quantity: '1L',
          category: 'DAIRY',
        ),
        ShoppingListItem(
          id: 'eggs',
          name: 'Free Range Eggs',
          quantity: '12 ct',
          category: 'DAIRY',
        ),
      ],
    ),
    ShoppingList(
      id: 'general-list',
      title: 'General List',
      subtitle: '2 items added by you',
      section: 'FAVORITES',
      iconType: 'list',
      items: [
        ShoppingListItem(
          id: 'heirloom-tomatoes',
          itemId: 201,
          name: 'Heirloom Tomatoes',
          quantity: '8g',
          category: 'PRODUCE',
        ),
        ShoppingListItem(
          id: 'baby-arugula',
          itemId: 202,
          name: 'Baby Arugula',
          quantity: '142 g',
          category: 'PRODUCE',
        ),
        ShoppingListItem(
          id: 'shallots',
          itemId: 203,
          name: 'Shallots',
          quantity: '2 ct',
          category: 'PRODUCE',
          checked: true,
        ),
        ShoppingListItem(
          id: 'cultured-butter',
          itemId: 204,
          name: 'Cultured Butter',
          quantity: '250g',
          category: 'DAIRY',
        ),
        ShoppingListItem(
          id: 'greek-yogurt',
          itemId: 205,
          name: 'Greek Yogurt',
          quantity: '907 g',
          category: 'DAIRY',
        ),
        ShoppingListItem(
          id: 'maldon-sea-salt',
          itemId: 206,
          name: 'Maldon Sea Salt',
          quantity: '1 box',
          category: 'PANTRY',
        ),
        ShoppingListItem(
          id: 'extra-virgin-olive-oil',
          itemId: 207,
          name: 'Extra Virgin Olive Oil',
          quantity: '500ml',
          category: 'PANTRY',
        ),
      ],
    ),
    ShoppingList(
      id: 'braised-short-rib',
      title: 'Braised Short Rib',
      subtitle: '6 items · Ready to shop',
      section: 'FROM YOUR RECIPES',
      iconType: 'image',
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=300&q=80',
      items: [
        ShoppingListItem(
          id: 'short-rib',
          name: 'Short Rib',
          quantity: '1kg',
          category: 'MEAT',
        ),
      ],
    ),
    ShoppingList(
      id: 'saffron-risotto',
      title: 'Saffron Risotto',
      subtitle: '3 items · Need to check pantry',
      section: 'FROM YOUR RECIPES',
      iconType: 'image',
      imageUrl:
          'https://images.unsplash.com/photo-1633436375153-d7045cb93e38?auto=format&fit=crop&w=300&q=80',
      items: [
        ShoppingListItem(
          id: 'arborio-rice',
          name: 'Arborio Rice',
          quantity: '500g',
          category: 'PANTRY',
        ),
      ],
    ),
    ShoppingList(
      id: 'manual-items',
      title: 'Manual Items',
      subtitle: '2 items added by you',
      section: 'OTHER LISTS',
      iconType: 'list',
      items: [
        ShoppingListItem(
          id: 'lemons',
          name: 'Lemons',
          quantity: '4 ct',
          category: 'PRODUCE',
        ),
      ],
    ),
  ];

  @override
  Future<List<ShoppingList>> getShoppingLists() async {
    return _lists;
  }

  @override
  Future<ShoppingList?> getShoppingListById(String id) async {
    for (final list in _lists) {
      if (list.id == id) return list;
    }

    return null;
  }

  @override
  Future<ShoppingListItem> updateItemPurchased({
    required String listId,
    required String itemId,
    required bool purchased,
  }) async {
    //mock version returns the updated item shape without touching a backend
    for (final list in _lists) {
      if (list.id != listId) continue;

      for (final item in list.items) {
        if (item.id == itemId) {
          return item.copyWith(checked: purchased);
        }
      }
    }

    throw StateError('Shopping list item not found.');
  }

  @override
  Future<ShoppingListItem> updateShoppingListItem({
    required String listId,
    required String itemId,
    int? ingId,
    String? name,
    required String quantity,
    required String unit,
    required bool purchased,
  }) async {
    final cleanedName = name?.trim();
    final cleanedQuantity = quantity.trim();
    final cleanedUnit = unit.trim();

    final hasIngredientId = ingId != null;
    final hasCustomName = cleanedName != null && cleanedName.isNotEmpty;

    if (hasIngredientId == hasCustomName) {
      throw ArgumentError(
        'Provide either an ingredient id or a custom item name, but not both.',
      );
    }

    final parsedQuantity = num.tryParse(cleanedQuantity);

    if (parsedQuantity == null || parsedQuantity <= 0) {
      throw ArgumentError('Quantity must be greater than zero.');
    }

    if (cleanedUnit.isEmpty) {
      throw ArgumentError('Unit is required.');
    }

    ShoppingListItem? existingItem;

    for (final list in _lists) {
      if (list.id != listId) continue;

      for (final item in list.items) {
        if (item.id == itemId) {
          existingItem = item;
          break;
        }
      }
    }

    if (existingItem == null) {
      throw StateError('Shopping list item not found.');
    }

    final displayQuantity = parsedQuantity % 1 == 0
        ? parsedQuantity.toInt().toString()
        : parsedQuantity.toString();

    //return updated item
    return existingItem.copyWith(
      ingId: ingId,
      name: hasCustomName ? cleanedName : existingItem.name,
      quantity: '$displayQuantity $cleanedUnit',
      unit: cleanedUnit,
      checked: purchased,
    );
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

    final displayName =
        hasIngredientId ? 'Mock catalogue ingredient' : cleanedName!;

    //item shape returned by backend
    return ShoppingListItem(
      id: hasIngredientId
          ? 'ingredient-$ingId'
          : displayName.toLowerCase().replaceAll(' ', '-'),
      itemId: 999,
      shoppingListId: int.tryParse(listId),
      ingId: ingId,
      name: displayName,
      quantity: parsedQuantity == null
          ? '-'
          : cleanedUnit.isEmpty
              ? '$parsedQuantity'
              : '$parsedQuantity $cleanedUnit',
      category: hasIngredientId ? 'CATALOGUE' : 'MANUAL',
      unit: cleanedUnit.isEmpty ? null : cleanedUnit,
    );
  }

  @override
  Future<CompleteShopResult> completeShop(String listId) async {
    //mock result mirrors the backend complete-shop response shape
    return const CompleteShopResult(
      addedToPantryCount: 1,
      skippedManualItems: ['Mock manual item'],
      canDeleteShoppingList: false,
    );
  }

  @override
  Future<ShoppingList> createShoppingList({
    required String name,
    String status = 'ACTIVE',
  }) async {
    final cleanedName = name.trim();

    if (cleanedName.isEmpty) {
      throw ArgumentError('Shopping list name is required.');
    }

    //mock version returns empty list
    return ShoppingList(
      id: cleanedName.toLowerCase().replaceAll(' ', '-'),
      shoppingListId: 999,
      userId: 1,
      title: cleanedName,
      subtitle: '0 items',
      section: 'OTHER LISTS',
      iconType: 'list',
      status: status,
      items: const [],
    );
  }

  @override
  Future<List<ShoppingListItem>> selectAllItems(String listId) async {
    final list = await getShoppingListById(listId);
    if (list == null) return [];

    //mock behaves like backend by returning updated item list
    return list.items.map((item) => item.copyWith(checked: true)).toList();
  }

  @override
  Future<List<ShoppingListItem>> deselectAllItems(String listId) async {
    final list = await getShoppingListById(listId);
    if (list == null) return [];

    //everything unchecked again
    return list.items.map((item) => item.copyWith(checked: false)).toList();
  }

  @override
  Future<void> deleteShoppingListItems({
    required String listId,
    required List<int> itemIds,
  }) async {
    if (itemIds.isEmpty) {
      throw ArgumentError('At least one item id is required.');
    }

    //mock does not persist, but it still checks that ids were supplied
  }

  @override
  Future<void> deleteShoppingList(String listId) async {
    //mock accepts delete request and provider removes it from local state
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

    final existingList = await getShoppingListById(listId);

    if (existingList == null) {
      throw StateError('Shopping list not found.');
    }

    //mock returns the renamed list, just like the backend would
    return existingList.copyWith(
      title: cleanedName,
      status: status,
    );
  }

  @override
  Future<ShoppingList> generateFromRecipe({
    required int recipeId,
    required String name,
    required bool includeAvailablePantryItems,
  }) async {
    return ShoppingList(
      id: '999',
      shoppingListId: 999,
      title: name,
      subtitle: '0 items',
      section: 'FROM YOUR RECIPES',
      iconType: 'list',
      items: const [],
    );
  }
}
