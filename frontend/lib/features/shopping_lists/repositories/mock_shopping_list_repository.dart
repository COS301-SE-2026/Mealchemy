import '../models/shopping_list.dart';
import '../models/shopping_list_item.dart';
import 'shopping_list_repository.dart';

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
          name: 'Heirloom Tomatoes',
          quantity: '8g',
          category: 'PRODUCE',
        ),
        ShoppingListItem(
          id: 'baby-arugula',
          name: 'Baby Arugula',
          quantity: '142 g',
          category: 'PRODUCE',
        ),
        ShoppingListItem(
          id: 'shallots',
          name: 'Shallots',
          quantity: '2 ct',
          category: 'PRODUCE',
          checked: true,
        ),
        ShoppingListItem(
          id: 'cultured-butter',
          name: 'Cultured Butter',
          quantity: '250g',
          category: 'DAIRY',
        ),
        ShoppingListItem(
          id: 'greek-yogurt',
          name: 'Greek Yogurt',
          quantity: '907 g',
          category: 'DAIRY',
        ),
        ShoppingListItem(
          id: 'maldon-sea-salt',
          name: 'Maldon Sea Salt',
          quantity: '1 box',
          category: 'PANTRY',
        ),
        ShoppingListItem(
          id: 'extra-virgin-olive-oil',
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
}