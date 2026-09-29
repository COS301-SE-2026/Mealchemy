import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/meal_plan/models/meal_plan_entry.dart';
import 'package:mealchemy/features/meal_plan/models/meal_slot.dart';

Map<String, dynamic> _json({Map<String, dynamic>? overrides}) => {
      'entryId': 55,
      'planId': 7,
      'recipeId': 981,
      'entryDate': '2026-09-29',
      'mealSlot': 'DINNER',
      'mealTime': '18:30',
      'title': null,
      'note': 'Meal prepped',
      'source': 'RECOMMENDED',
      'addedBy': 101,
      'recipe': {
        'recipeId': 981,
        'title': 'Penne Alla Vodka',
        'cuisineType': 'ITALIAN',
        'photoUrl': 'https://images.unsplash.com/photo-1.jpg',
      },
      ...?overrides,
    };

void main() {
  group('MealPlanEntry.fromJson', () {
    test('parses entry fields and the embedded recipe', () {
      final e = MealPlanEntry.fromJson(_json());

      expect(e.entryId, 55);
      expect(e.planId, 7);
      expect(e.recipeId, 981);
      expect(e.entryDate, DateTime(2026, 9, 29));
      expect(e.mealSlot, MealSlot.dinner);
      expect(e.mealTime, const TimeOfDay(hour: 18, minute: 30));
      expect(e.note, 'Meal prepped');
      expect(e.source, MealEntrySource.recommended);
      expect(e.recipe?.title, 'Penne Alla Vodka');
      expect(e.recipe?.photoUrl, isNotNull);
    });

    test('accepts HH:mm:ss times from Spring', () {
      final e = MealPlanEntry.fromJson(_json(overrides: {'mealTime': '07:45:00'}));

      expect(e.mealTime, const TimeOfDay(hour: 7, minute: 45));
    });

    test('defaults source to manual and allows a missing recipe', () {
      final e = MealPlanEntry.fromJson(_json(overrides: {'source': null, 'recipe': null}));

      expect(e.source, MealEntrySource.manual);
      expect(e.recipe, isNull);
    });
  });

  group('displayTitle', () {
    test('uses the title override when set', () {
      final e = MealPlanEntry.fromJson(_json(overrides: {'title': 'Fish Night'}));

      expect(e.displayTitle, 'Fish Night');
    });

    test('falls back to the recipe title, then empty', () {
      expect(MealPlanEntry.fromJson(_json()).displayTitle, 'Penne Alla Vodka');
      expect(
        MealPlanEntry.fromJson(_json(overrides: {'recipe': null})).displayTitle,
        '',
      );
    });
  });

  group('toRequestJson', () {
    test('sends wire formats and leaves out server fields', () {
      final body = MealPlanEntry(
        recipeId: 981,
        entryDate: DateTime(2026, 10, 3),
        mealSlot: MealSlot.breakfast,
        mealTime: const TimeOfDay(hour: 8, minute: 5),
        note: 'Leftovers',
      ).toRequestJson();

      expect(body['recipeId'], 981);
      expect(body['entryDate'], '2026-10-03');
      expect(body['mealSlot'], 'BREAKFAST');
      expect(body['mealTime'], '08:05');
      expect(body['title'], isNull);
      expect(body['note'], 'Leftovers');
      expect(body.containsKey('entryId'), isFalse);
      expect(body.containsKey('source'), isFalse);
    });
  });

  group('copyWith', () {
    test('changes only what is passed and keeps ids and source', () {
      final e = MealPlanEntry.fromJson(_json());
      final moved = e.copyWith(mealSlot: MealSlot.lunch, mealTime: const TimeOfDay(hour: 12, minute: 0));

      expect(moved.mealSlot, MealSlot.lunch);
      expect(moved.mealTime, const TimeOfDay(hour: 12, minute: 0));
      expect(moved.entryId, e.entryId);
      expect(moved.recipeId, e.recipeId);
      expect(moved.source, MealEntrySource.recommended);
      expect(moved.note, e.note);
    });
  });
}