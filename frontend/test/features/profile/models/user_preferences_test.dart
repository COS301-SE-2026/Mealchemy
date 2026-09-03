import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/profile/models/user_preferences.dart';

void main() {
  group('UserPreferences.fromJson', () {
    test('parses a full payload ', () {
      final prefs = UserPreferences.fromJson(<String, dynamic>{
        'dietary_restrictions': ['GLUTEN_FREE'],
        'allergies': ['PEANUTS', 'SHELLFISH'],
        'disliked_ingredients': ['Hummus, commercial'],
        'flavour_profile': ['ITALIAN'],
        'nutritional_goals': ['HIGH_PROTEIN'],
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
    test('emits all five snake_case arrays', () {
      const prefs = UserPreferences(
        dietaryRestrictions: ['VEGAN'],
        allergies: ['SOY'],
        dislikedIngredients: ['Cilantro'],
        flavourProfile: ['japanese'],
        nutritionalGoals: ['LOW_CARB'],
      );

      final json = prefs.toJson();
      expect(json['dietary_restrictions'], ['VEGAN']);
      expect(json['allergies'], ['SOY']);
      expect(json['disliked_ingredients'], ['Cilantro']);
      expect(json['flavour_profile'], ['japanese']);
      expect(json['nutritional_goals'], ['LOW_CARB']);
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