import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/pantry/repositories/mock_pantry_repository.dart';
import 'package:mealchemy/features/pantry/widgets/pantry_item_card.dart';

void main() {
  //ensure mock data returns
  test('MockPantryRepository returns pantry summary data', () async {
    //mock repo instance
    final repository = MockPantryRepository();

    final summary = await repository.getPantrySummary();

    expect(summary.totalItems, 42);
    expect(summary.freshnessPercent, 84);
    expect(summary.optimizationPercent, 72);
  });

  //ingredients returned correctly (details)
  test('MockPantryRepository returns pantry ingredients', () async {
    final repository = MockPantryRepository();

    //fetch mock data
    final ingredients = await repository.getPantryIngredients();

    expect(ingredients, isNotEmpty);
    expect(ingredients.first.name, 'Chicken Breast');
    expect(ingredients.first.status, PantryItemStatus.fresh);
  });

  //expected category data
  test('MockPantryRepository returns ingredient categories', () async {
    final repository = MockPantryRepository();

    final categories = await repository.getIngredientCategories();

    expect(categories, contains('produce'));
    expect(categories, contains('dairy'));
    expect(categories, contains('other'));
  });
}