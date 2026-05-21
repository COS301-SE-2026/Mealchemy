import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe_ingredient.dart';

void main() {
  group('RecipeIngredient.fromJson', () {
    test('parses a full payload with snake_case keys', () {
      final json = <String, dynamic>{
        'ingredient_id': 101,
        'recipe_id': 1,
        'name_raw': 'Arborio rice',
        'quantity': 320.0,
        'unit': 'g',
        'sort_order': 1,
      };

      final ingredient = RecipeIngredient.fromJson(json);

      expect(ingredient.ingredientId, 101);
      expect(ingredient.recipeId, 1);
      expect(ingredient.nameRaw, 'Arborio rice');
      expect(ingredient.quantity, 320.0);
      expect(ingredient.unit, 'g');
      expect(ingredient.sortOrder, 1);
    });

    test('parses a payload with null quantity and unit', () {
      final json = <String, dynamic>{
        'ingredient_id': 102,
        'recipe_id': 1,
        'name_raw': 'Salt to taste',
        'quantity': null,
        'unit': null,
        'sort_order': 5,
      };

      final ingredient = RecipeIngredient.fromJson(json);

      expect(ingredient.nameRaw, 'Salt to taste');
      expect(ingredient.quantity, isNull);
      expect(ingredient.unit, isNull);
    });

    test('coerces an integer quantity into a double', () {
      //backend will likely send DECIMAL(10,3) values as int when there are no fractionals
      final json = <String, dynamic>{
        'ingredient_id': 103,
        'recipe_id': 1,
        'name_raw': 'Eggs',
        'quantity': 3,
        'unit': null,
        'sort_order': 1,
      };

      final ingredient = RecipeIngredient.fromJson(json);

      expect(ingredient.quantity, 3.0);
      expect(ingredient.quantity, isA<double>());
    });

    test('defaults sort_order to 0 when missing', () {
      final json = <String, dynamic>{
        'ingredient_id': 104,
        'recipe_id': 1,
        'name_raw': 'Mystery Ingredient',
      };

      final ingredient = RecipeIngredient.fromJson(json);

      expect(ingredient.sortOrder, 0);
    });
  });
}
