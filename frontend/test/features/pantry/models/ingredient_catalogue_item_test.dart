import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/pantry/models/ingredient_catalogue_item.dart';

void main() {
  test('maps existing local catalogue search result', () {
    final ingredient = IngredientCatalogueItem.fromJson({
      'ing_id': 1,
      'name': 'Hummus',
      'category': 'Legumes and Legume Products',
      'source_id': null,
      'source_api': null,
    });

    expect(ingredient.ingId, 1);
    expect(ingredient.name, 'Hummus');
    expect(
      ingredient.category,
      'Legumes and Legume Products',
    );
    expect(ingredient.sourceId, isNull);
    expect(ingredient.sourceApi, isNull);
    expect(ingredient.requiresImport, isFalse);
    expect(ingredient.isLocalCatalogueItem, isTrue);
  });

  test('maps unsaved USDA search result without inventing an id or category',
      () {
    final ingredient = IngredientCatalogueItem.fromJson({
      'ing_id': null,
      'name': 'Kimchi',
      'category': null,
      'source_id': '2710077',
      'source_api': 'USDA',
    });

    expect(ingredient.ingId, isNull);
    expect(ingredient.name, 'Kimchi');
    expect(ingredient.category, isNull);
    expect(ingredient.sourceId, '2710077');
    expect(ingredient.sourceApi, 'USDA');
    expect(ingredient.requiresImport, isTrue);
    expect(ingredient.isLocalCatalogueItem, isFalse);
  });

  test('maps numeric-string catalogue id without losing its value', () {
    final ingredient = IngredientCatalogueItem.fromJson({
      'ing_id': '11',
      'name': 'Chicken Breast',
      'category': 'Poultry',
      'source_id': null,
      'source_api': null,
    });

    expect(ingredient.ingId, 11);
    expect(ingredient.requiresImport, isFalse);
  });
}
