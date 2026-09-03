import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/pantry/models/ingredient_category.dart';

void main() {
  test('IngredientCategory maps backend JSON', () {
    final category = IngredientCategory.fromJson({
      'category_id': 4,
      'name': 'Dairy',
    });

    expect(category.categoryId, 4);
    expect(category.name, 'Dairy');
  });

  test('IngredientCategory accepts numeric string category id', () {
    final category = IngredientCategory.fromJson({
      'category_id': '7',
      'name': 'Baked Products',
    });

    expect(category.categoryId, 7);
    expect(category.name, 'Baked Products');
  });

  test('IngredientCategory rejects missing category id', () {
    expect(
      () => IngredientCategory.fromJson({
        'name': 'Dairy',
      }),
      throwsFormatException,
    );
  });
}
