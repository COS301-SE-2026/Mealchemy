import '../models/ingredient_catalogue_item.dart';
import 'ingredient_catalogue_repository.dart';

//not tied to the real V29 seed; a reasonable set for building the editor
class MockIngredientCatalogueRepository
    implements IngredientCatalogueRepository {
  static const List<IngredientCatalogueItem> _items = [
    IngredientCatalogueItem(ingId: 1, name: 'Chicken Breast', category: 'Meat'),
    IngredientCatalogueItem(ingId: 2, name: 'Broccoli', category: 'Vegetable'),
    IngredientCatalogueItem(ingId: 3, name: 'Brown Rice', category: 'Grain'),
    IngredientCatalogueItem(ingId: 4, name: 'Cherry Tomatoes', category: 'Vegetable'),
    IngredientCatalogueItem(ingId: 5, name: 'Mozzarella', category: 'Dairy'),
    IngredientCatalogueItem(ingId: 6, name: 'Basil', category: 'Herb'),
    IngredientCatalogueItem(ingId: 7, name: 'Penne Pasta', category: 'Grain'),
    IngredientCatalogueItem(ingId: 8, name: 'Salmon Fillet', category: 'Fish'),
    IngredientCatalogueItem(ingId: 9, name: 'Black Beans', category: 'Legume'),
    IngredientCatalogueItem(ingId: 10, name: 'Sweetcorn', category: 'Vegetable'),
    IngredientCatalogueItem(ingId: 11, name: 'Garlic', category: 'Vegetable'),
    IngredientCatalogueItem(ingId: 12, name: 'Olive Oil', category: 'Oil'),
    IngredientCatalogueItem(ingId: 13, name: 'Lemon', category: 'Fruit'),
    IngredientCatalogueItem(ingId: 14, name: 'Avocado', category: 'Fruit'),
    IngredientCatalogueItem(ingId: 15, name: 'Sour Cream', category: 'Dairy'),
  ];

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 250));

  @override
  Future<List<IngredientCatalogueItem>> getAll() async {
    await _delay();
    return _items;
  }

  @override
  Future<List<IngredientCatalogueItem>> search(String query) async {
    await _delay();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items
        .where((i) => i.name.toLowerCase().contains(q))
        .toList();
  }
}