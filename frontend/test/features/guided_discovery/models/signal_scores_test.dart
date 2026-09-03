import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/guided_discovery/models/signal_scores.dart';

void main() {
  group('SignalScores.fromJson', () {
    test('reads pantry_match as snake_case and coerces ints to doubles', () {
      final scores = SignalScores.fromJson({
        'pantry_match': 0.9,
        'cuisine': 1.0,
        'nutrition': 0.5,
        'freshness': 0.3,
        'novelty': 1.0,
      });
      expect(scores.pantryMatch, 0.9);
      expect(scores.cuisine, 1.0);
      expect(scores.nutrition, 0.5);
      expect(scores.freshness, 0.3);
      expect(scores.novelty, 1.0);
    });

    test('defaults missing signals to 0.0', () {
      final scores = SignalScores.fromJson({'pantry_match': 0.7});
      expect(scores.pantryMatch, 0.7);
      expect(scores.cuisine, 0.0);
      expect(scores.nutrition, 0.0);
      expect(scores.freshness, 0.0);
      expect(scores.novelty, 0.0);
    });
  });

  group('SignalScores.toJson', () {
    test('emits pantry_match snake_case with all five signals', () {
      const scores = SignalScores(
        pantryMatch: 0.9,
        cuisine: 0.8,
        nutrition: 0.5,
        freshness: 0.3,
        novelty: 1.0,
      );

      expect(scores.toJson(), {
        'pantry_match': 0.9,
        'cuisine': 0.8,
        'nutrition': 0.5,
        'freshness': 0.3,
        'novelty': 1.0,
      });
    });

    test('round-trips through fromJson', () {
      const original = SignalScores(
        pantryMatch: 0.1,
        cuisine: 0.2,
        nutrition: 0.3,
        freshness: 0.4,
        novelty: 0.5,
      );
      final restored = SignalScores.fromJson(original.toJson());
      expect(restored.pantryMatch, original.pantryMatch);
      expect(restored.cuisine, original.cuisine);
      expect(restored.nutrition, original.nutrition);
      expect(restored.freshness, original.freshness);
      expect(restored.novelty, original.novelty);
    });
  });
}