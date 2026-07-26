import '../models/pantry_ingredient.dart';
import '../models/pantry_summary.dart';
import '../widgets/pantry_item_card.dart';
import 'pantry_repository.dart';

//mock data (while API not connected)
class MockPantryRepository implements PantryRepository {
  @override
  Future<PantrySummary> getPantrySummary() async {
    return const PantrySummary(
      totalItems: 42,
      freshnessPercent: 84,
      categoryCount: 6,
      optimizationPercent: 72,
    );
  }

  @override
  Future<void> addPantryIngredient(PantryIngredient ingredient) async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Future<List<PantryFilter>> getPantryFilters() async {
    return const [
      PantryFilter(label: 'All', count: 42),
      PantryFilter(label: 'Proteins', count: 2),
      PantryFilter(label: 'Vegetables', count: 2),
      PantryFilter(label: 'Dairy', count: 2),
    ];
  }

  @override
  Future<List<PantryIngredient>> getPantryIngredients() async {
    return const [
      PantryIngredient(
        pIngredientId: 1,
        ingId: 101,
        name: 'Chicken Breast',
        details: '800g • Refrigerated',
        category: 'Proteins',
        status: PantryItemStatus.fresh,
        quantity: '800',
        unit: 'g',
      ),
      PantryIngredient(
        pIngredientId: 2,
        ingId: 102,
        name: 'Salmon Fillet',
        details: '150g • Use by tomorrow',
        category: 'Proteins',
        status: PantryItemStatus.low,
        quantity: '150',
        unit: 'g',
      ),
      PantryIngredient(
        pIngredientId: 3,
        ingId: 103,
        name: 'Cherry Tomatoes',
        details: '~10 pcs • Pantry',
        category: 'Vegetables',
        status: PantryItemStatus.low,
        quantity: '10',
        unit: 'pcs',
      ),
      PantryIngredient(
        pIngredientId: 4,
        ingId: 104,
        name: 'Baby Spinach',
        details: '200g • Expired 2 days ago',
        category: 'Vegetables',
        status: PantryItemStatus.expired,
        quantity: '200',
        unit: 'g',
      ),
      PantryIngredient(
        pIngredientId: 5,
        ingId: 105,
        name: 'Parmesan Cheese',
        details: '150g • Wedge',
        category: 'Dairy',
        status: PantryItemStatus.fresh,
        quantity: '150',
        unit: 'g',
      ),
      PantryIngredient(
        pIngredientId: 6,
        ingId: 106,
        name: 'Full Cream Milk',
        details: '1L • Carton',
        category: 'Dairy',
        status: PantryItemStatus.low,
        quantity: '1',
        unit: 'L',
      ),
    ];
  }

  @override
  Future<List<String>> getIngredientCategories() async {
    return const [
      'produce',
      'dairy',
      'meat',
      'poultry',
      'seafood',
      'grains',
      'legumes',
      'spices',
      'condiments',
      'beverages',
      'frozen',
      'snacks',
      'other',
    ];
  }

  @override
  Future<PantryIngredient> addPantryIngredient({
    required int ingId,
    required String quantity,
    required String unit,
  }) async {
    //mock version just returns a pantry-looking item without touching backend
    return PantryIngredient(
      pIngredientId: 999,
      ingId: ingId,
      name: 'Mock ingredient',
      details: '$quantity$unit • Manual entry',
      category: 'Other',
      status: PantryItemStatus.fresh,
      quantity: quantity,
      unit: unit,
    );
  }

  @override
  Future<void> deletePantryIngredient(int pIngredientId) async {
    //mock delete does nothing because the provider updates local state
  }

  @override
  Future<PantryIngredient> updatePantryIngredient({
    required int pIngredientId,
    required int ingId,
    required String quantity,
    required String unit,
  }) async {
    //mock update returns the same pantry row shape the backend would return
    return PantryIngredient(
      pIngredientId: pIngredientId,
      ingId: ingId,
      name: 'Mock ingredient',
      details: '$quantity$unit • Pantry',
      category: 'Other',
      status: PantryItemStatus.fresh,
      quantity: quantity,
      unit: unit,
    );
  }
}
