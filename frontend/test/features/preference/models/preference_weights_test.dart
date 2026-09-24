import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/preference/models/preference_weights.dart';


void main() {
  group('PreferenceWeights', () {
    test('total sums all five weights', () {
      const w = PreferenceWeights(
        pantryMatch: 0.4,
        cuisine: 0.25,
        nutrition: 0.1,
        freshness: 0.15,
        novelty: 0.1,
      );

      expect(w.total, closeTo(1.0, 0.0001));
    });

    test('shareOf returns a value\'s proportion of the total', () {
      const w = PreferenceWeights(
        pantryMatch: 3,
        cuisine: 1,
        nutrition: 0,
        freshness: 0,
        novelty: 0,
      );
      expect(w.shareOf(w.pantryMatch), closeTo(0.75, 0.0001));
      expect(w.shareOf(w.cuisine), closeTo(0.25, 0.0001));
    });

    test('normalized scales the weights to sum 1.0, keeping proportions', () {
      const w = PreferenceWeights(
        pantryMatch: 1,
        cuisine: 1,
        nutrition: 1,
        freshness: 1,
        novelty: 1,
      );

      final n = w.normalized();
      expect(n.total, closeTo(1.0, 0.0001));
      expect(n.pantryMatch, closeTo(0.2, 0.0001));
    });

    test('normalized falls back to defaults when everything is zero', () {
      const w = PreferenceWeights(
        pantryMatch: 0,
        cuisine: 0,
        nutrition: 0,
        freshness: 0,
        novelty: 0,
      );

      expect(w.normalized(), PreferenceWeights.defaults);
    });

    test('fromJson reads the snake_case signal keys', () {
      final w = PreferenceWeights.fromJson(const {
        'pantry_match': 0.4,
        'cuisine': 0.25,
        'nutrition': 0.1,
        'freshness': 0.15,
        'novelty': 0.1,
      });

      expect(w.pantryMatch, 0.4);
      expect(w.novelty, 0.1);
    });

    test('toJson round trips through fromJson', () {
      const w = PreferenceWeights.defaults;
      expect(PreferenceWeights.fromJson(w.toJson()).total, closeTo(1.0, 0.0001));
    });
  });
}