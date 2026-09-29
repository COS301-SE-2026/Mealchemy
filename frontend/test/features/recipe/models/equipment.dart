import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/equipment.dart';
import 'package:mealchemy/features/recipe/models/recipe.dart';

void main() {
  group('Equipment.fromJson', () {
    test('maps equipmentId to id and ignores the join-row fields', () {
      final equipment = Equipment.fromJson({
        'recipeEquipmentId': 41,
        'recipeId': 12,
        'equipmentId': 3,
        'value': 'OVEN',
        'label': 'Oven',
      });

      expect(equipment.id, 3);
      expect(equipment.value, 'OVEN');
      expect(equipment.label, 'Oven');
    });
  });

  group('Recipe equipmentIds', () {
    const oven = Equipment(id: 3, value: 'OVEN', label: 'Oven');
    const blender = Equipment(id: 5, value: 'BLENDER', label: 'Blender');

    test('sends equipment ids when equipment is loaded', () {
      const recipe = Recipe(
        recipeId: 12,
        title: 'Penne Alla Vodka',
        equipment: [oven, blender],
      );
      expect(recipe.toCreateRequestJson()['equipmentIds'], [3, 5]);
      expect(recipe.toFullRequestJson()['equipmentIds'], [3, 5]);
    });

    test('sends an empty list when all equipment was removed', () {
      const recipe = Recipe(recipeId: 12, title: 'Greek Salad', equipment: []);
      expect(recipe.toFullRequestJson()['equipmentIds'], isEmpty);
    });

    test('leaves equipmentIds out when equipment was never loaded', () {
      const recipe = Recipe(recipeId: 12, title: 'Penne Alla Vodka');
      expect(recipe.toCreateRequestJson().containsKey('equipmentIds'), isFalse);
      expect(recipe.toFullRequestJson().containsKey('equipmentIds'), isFalse);
    });

    test('copyWith carries equipment over', () {
      const recipe = Recipe(
        recipeId: 12,
        title: 'Penne Alla Vodka',
        equipment: [oven],
      );

      expect(recipe.copyWith(title: 'Vodka Penne').equipment, [oven]);
    });
  });
}