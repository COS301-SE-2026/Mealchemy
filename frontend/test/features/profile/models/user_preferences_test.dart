import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/profile/models/user_preferences.dart';

void main() {
  group('UserPreferences.fromJson', () {
    test('parses a full payload ', () {
      final prefs = UserPreferences.fromJson(<String, dynamic>{
        'dietaryRestrictions': ['GLUTEN_FREE'],
        'allergies': ['PEANUTS', 'SHELLFISH'],
        'dislikedIngredients': ['Hummus, commercial'],
        'flavourProfile': ['ITALIAN'],
        'nutritionalGoals': ['HIGH_PROTEIN'],
      });
      expect(prefs.dietaryRestrictions, ['GLUTEN_FREE']);
      expect(prefs.allergies, ['PEANUTS', 'SHELLFISH']);
      expect(prefs.dislikedIngredients, ['Hummus, commercial']);
      expect(prefs.flavourProfile, ['ITALIAN']);
      expect(prefs.nutritionalGoals, ['HIGH_PROTEIN']);
    });

    test('defaults every field to an empty list when keys are missing', () {
      final prefs = UserPreferences.fromJson(<String, dynamic>{});
      expect(prefs.dietaryRestrictions, isEmpty);
      expect(prefs.allergies, isEmpty);
      expect(prefs.dislikedIngredients, isEmpty);
      expect(prefs.flavourProfile, isEmpty);
      expect(prefs.nutritionalGoals, isEmpty);
    });
  });

  group('UserPreferences.toJson', () {
    test('emits all five camelCase arrays', () {
      const prefs = UserPreferences(
        dietaryRestrictions: ['VEGAN'],
        allergies: ['SOY'],
        dislikedIngredients: ['Cilantro'],
        flavourProfile: ['japanese'],
        nutritionalGoals: ['LOW_CARB'],
      );

      final json = prefs.toJson();
      expect(json['dietaryRestrictions'], ['VEGAN']);
      expect(json['allergies'], ['SOY']);
      expect(json['dislikedIngredients'], ['Cilantro']);
      expect(json['flavourProfile'], ['japanese']);
      expect(json['nutritionalGoals'], ['LOW_CARB']);
    });

    test('round trips through fromJson', () {
      const original = UserPreferences(
        dietaryRestrictions: ['GLUTEN_FREE'],
        allergies: ['PEANUTS'],
        dislikedIngredients: ['Hummus, commercial'],
        flavourProfile: ['ITALIAN'],
        nutritionalGoals: ['HIGH_PROTEIN'],
      );

      final restored = UserPreferences.fromJson(original.toJson());

      expect(restored.dietaryRestrictions, original.dietaryRestrictions);
      expect(restored.dislikedIngredients, original.dislikedIngredients);
      expect(restored.nutritionalGoals, original.nutritionalGoals);
    });
  });
}