import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';

void main() {
  group('RecipeIngredient.fromJson', () {
    test('parses a full payload with camelCase keys', () {
      final json = <String, dynamic>{
        'ingredientId': 101,
        'recipeId': 1,
        'ingId': 16,
        'quantity': 320.0,
        'unit': 'g',
        'sortOrder': 1,
      };

      final ingredient = RecipeIngredient.fromJson(json);

      expect(ingredient.ingredientId, 101);
      expect(ingredient.recipeId, 1);
      expect(ingredient.ingId, 16);
      expect(ingredient.quantity, 320.0);
      expect(ingredient.unit, 'g');
      expect(ingredient.sortOrder, 1);
    });

    test('parses a payload with null quantity and unit', () {
      final json = <String, dynamic>{
        'ingredientId': 102,
        'recipeId': 1,
        'ingId': 17,
        'quantity': null,
        'unit': null,
        'sortOrder': 5,
      };

      final ingredient = RecipeIngredient.fromJson(json);

      expect(ingredient.ingId, 17);
      expect(ingredient.quantity, isNull);
      expect(ingredient.unit, isNull);
    });

    test('coerces an integer quantity into a double', () {
      //backend will likely send DECIMAL(10,3) values as int when there are no fractionals
      final json = <String, dynamic>{
        'ingredientId': 103,
        'recipeId': 1,
        'ingId': 11,
        'quantity': 3,
        'unit': null,
        'sortOrder': 1,
      };

      final ingredient = RecipeIngredient.fromJson(json);

      expect(ingredient.quantity, 3.0);
      expect(ingredient.quantity, isA<double>());
    });
    test('leaves ingredientId null when absent (unsaved row)', () {
      final json = <String, dynamic>{
        'ingId': 5,
        'quantity': 150,
        'unit': 'g',
        'sortOrder': 2,
      };

      final ingredient = RecipeIngredient.fromJson(json);

      expect(ingredient.ingredientId, isNull);
      expect(ingredient.recipeId, isNull);
      expect(ingredient.ingId, 5);
    });

    test('defaults sortOrder to 0 when missing', () {
      final json = <String, dynamic>{
        'ingId': 3,
        'quantity': 200,
        'unit': 'g',
      };

      final ingredient = RecipeIngredient.fromJson(json);

      expect(ingredient.sortOrder, 0);
    });
  });
}
