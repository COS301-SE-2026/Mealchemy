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

    test('rebalance holds the total at 1.0 and applies the new value', () {
      final w = PreferenceWeights.defaults.rebalance(0, 0.6);
      expect(w.pantryMatch, closeTo(0.6, 0.0001));
      expect(w.total, closeTo(1.0, 0.0001));
    });

    test('rebalance shrinks the others but keeps their proportions', () {
      const w = PreferenceWeights(
        pantryMatch: 0.2,
        cuisine: 0.4,
        nutrition: 0.2,
        freshness: 0.1,
        novelty: 0.1,
      );

      final r = w.rebalance(0, 0.6);

      expect(r.cuisine, lessThan(w.cuisine));
      expect(r.cuisine / r.nutrition, closeTo(w.cuisine / w.nutrition, 0.0001));
    });

    test('rebalance splits evenl  when the others are all  zero', () {
      const w = PreferenceWeights(
        pantryMatch: 1,
        cuisine: 0,
        nutrition: 0,
        freshness: 0,
        novelty: 0,
      );

      final r = w.rebalance(0, 0.6);

      expect(r.cuisine, closeTo(0.1, 0.0001));
      expect(r.novelty, closeTo(0.1, 0.0001));
      expect(r.total, closeTo(1.0, 0.0001));
    });

    test('rebalance to 1.0 zeroe  the other four', () {
      final w = PreferenceWeights.defaults.rebalance(2, 1.0);
      expect(w.nutrition, closeTo(1.0, 0.0001));
      expect(w.pantryMatch, closeTo(0, 0.0001));
      expect(w.total, closeTo(1.0, 0.0001));
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