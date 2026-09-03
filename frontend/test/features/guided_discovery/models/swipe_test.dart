import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/guided_discovery/models/signal_scores.dart';
import 'package:mealchemy/features/guided_discovery/models/swipe.dart';

void main() {
  const signals = SignalScores(
    pantryMatch: 0.9,
    cuisine: 0.8,
    nutrition: 0.5,
    freshness: 0.3,
    novelty: 1.0,
  );


  group('SwipeAction', () {
    test('serializes to the backend wire strings', () {
      expect(SwipeAction.liked.wire, 'LIKED');
      expect(SwipeAction.disliked.wire, 'DISLIKED');
      expect(SwipeAction.skipped.wire, 'SKIPPED');
    });
  });

  group('SwipeRequest.toJson', () {
    test('uses  snake_case keys and echoes the signal scores ', () {
      const request = SwipeRequest(
        recipeId: 100,
        cuisineValue: 'ITALIAN',
        action: SwipeAction.liked,
        signalScores: signals,
      );

      final json = request.toJson();

      expect(json['recipe_id'], 100);
      expect(json['cuisine_value'], 'ITALIAN');
      expect(json['action'], 'LIKED');
      expect(json['signal_scores'], signals.toJson());
      expect(json['signal_scores']['pantry_match'], 0.9);
    });
  });

  group('SwipeResponse.fromJson', () {
    test('parses a full response', () {
      final response = SwipeResponse.fromJson({
        'swipe_id': 55,
        'recipe_id': 100,
        'cuisine_value': 'ITALIAN',
        'action': 'LIKED',
        'swiped_at': '2026-09-02T21:19:36.844531Z',
      });

      expect(response.swipeId, 55);
      expect(response.recipeId, 100);
      expect(response.cuisineValue, 'ITALIAN');
      expect(response.action, SwipeAction.liked);
      expect(response.swipedAt, isNotNull);
    });

    test('leaves swipedAt null when absent', () {
      final response = SwipeResponse.fromJson({
        'swipe_id': 1,
        'recipe_id': 2,
        'cuisine_value': 'GREEK',
        'action': 'SKIPPED',
        'swiped_at': null,
      });

      expect(response.swipedAt, isNull);
      expect(response.action, SwipeAction.skipped);
    });

    test('falls back to skipped on an unknown action', () {
      final response = SwipeResponse.fromJson({
        'swipe_id': 1,
        'recipe_id': 2,
        'cuisine_value': 'GREEK',
        'action': 'SOMETHING_NEW',
        'swiped_at': null,
      });

      expect(response.action, SwipeAction.skipped);
    });
  });
}