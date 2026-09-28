import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/meal_plan/models/meal_slot.dart';

void main() {
  group('MealSlot', () {
    test('maps wire values both ways', () {
      expect(MealSlot.fromValue('BREAKFAST'), MealSlot.breakfast);
      expect(MealSlot.fromValue('DINNER'), MealSlot.dinner);
      expect(MealSlot.snack.value, 'SNACK');
      expect(MealSlot.snack.label, 'Other');
    });

    test('allows times inside the slot window, edges included', () {
      expect(MealSlot.lunch.allows(const TimeOfDay(hour: 12, minute: 30)), isTrue);
      expect(MealSlot.lunch.allows(const TimeOfDay(hour: 11, minute: 0)), isTrue);
      expect(MealSlot.lunch.allows(const TimeOfDay(hour: 16, minute: 0)), isTrue);
    });

    test('rejects times outside the slot window', () {
      expect(MealSlot.breakfast.allows(const TimeOfDay(hour: 18, minute: 0)), isFalse);
      expect(MealSlot.dinner.allows(const TimeOfDay(hour: 9, minute: 0)), isFalse);
    });

    test('snack has no window', () {
      expect(MealSlot.snack.allows(const TimeOfDay(hour: 2, minute: 0)), isTrue);
      expect(MealSlot.snack.allows(const TimeOfDay(hour: 23, minute: 59)), isTrue);
    });

    test('unknown value throws', () {
      expect(() => MealSlot.fromValue('BRUNCH'), throwsStateError);
    });
  });

  group('MealEntrySource', () {
    test('maps wire values', () {
      expect(MealEntrySource.fromValue('MANUAL'), MealEntrySource.manual);
      expect(MealEntrySource.fromValue('RECOMMENDED'), MealEntrySource.recommended);
    });
  });
}