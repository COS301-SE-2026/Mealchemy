import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/ingredients/models/ingredient_catalogue_item.dart';

void main() {
  group('IngredientCatalogueItem.fromJson', () {
    test('parses a full payload (ing_id is snake per @JsonProperty)', () {
      final json = <String, dynamic>{
        'ing_id': 3,
        'name': 'Brown Rice',
        'category': 'Grain',
      };

      final item = IngredientCatalogueItem.fromJson(json);

      expect(item.ingId, 3);
      expect(item.name, 'Brown Rice');
      expect(item.category, 'Grain');
    });

    test('parses a payload with null category', () {
      final json = <String, dynamic>{
        'ing_id': 7,
        'name': 'Penne Pasta',
        'category': null,
      };

      final item = IngredientCatalogueItem.fromJson(json);

      expect(item.ingId, 7);
      expect(item.name, 'Penne Pasta');
      expect(item.category, isNull);
    });

    test('treats a missing category as null', () {
      final json = <String, dynamic>{
        'ing_id': 12,
        'name': 'Olive Oil',
      };

      final item = IngredientCatalogueItem.fromJson(json);

      expect(item.category, isNull);
    });
  });

  test('parses an external USDA search result', () {
    final json = <String, dynamic>{
      'ing_id': null,
      'name': 'Kimchi',
      'category': null,
      'source_id': '2710077',
      'source_api': 'USDA',
    };

    final item = IngredientCatalogueItem.fromJson(json);

    expect(item.ingId, isNull);
    expect(item.name, 'Kimchi');
    expect(item.category, isNull);
    expect(item.sourceId, '2710077');
    expect(item.sourceApi, 'USDA');
    expect(item.requiresImport, isTrue);
    expect(item.isLocalCatalogueItem, isFalse);
  });

  test('identifies a local catalogue result', () {
    final item = IngredientCatalogueItem.fromJson({
      'ing_id': 12,
      'name': 'Olive Oil',
      'category': 'Oil',
      'source_id': null,
      'source_api': null,
    });

    expect(item.ingId, 12);
    expect(item.requiresImport, isFalse);
    expect(item.isLocalCatalogueItem, isTrue);
  });

  test('accepts a numeric string ingredient id', () {
    final item = IngredientCatalogueItem.fromJson({
      'ing_id': '15',
      'name': 'Sour Cream',
      'category': 'Dairy',
    });

    expect(item.ingId, 15);
  });
}
