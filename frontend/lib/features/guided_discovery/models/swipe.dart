// Request and response models for recording a discovery swipe.
import 'signal_scores.dart';

enum SwipeAction {
  liked('LIKED'),
  disliked('DISLIKED'),
  skipped('SKIPPED');

  const SwipeAction(this.wire);
  final String wire;
}

class SwipeRequest {
  final int recipeId;
  final String cuisineValue;
  final SwipeAction action;
  final SignalScores signalScores;

  const SwipeRequest({
    required this.recipeId,
    required this.cuisineValue,
    required this.action,
    required this.signalScores,
  });

  Map<String, dynamic> toJson() => {
        'recipe_id': recipeId,
        'cuisine_value': cuisineValue,
        'action': action.wire,
        'signal_scores': signalScores.toJson(),
      };
}


class SwipeResponse {
  final int swipeId;
  final int recipeId;
  final String cuisineValue;
  final SwipeAction action;
  final DateTime? swipedAt;

  const SwipeResponse({
    required this.swipeId,
    required this.recipeId,
    required this.cuisineValue,
    required this.action,
    this.swipedAt,
  });

  factory SwipeResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['action'] as String;
    return SwipeResponse(
      swipeId: json['swipe_id'] as int,
      recipeId: json['recipe_id'] as int,
      cuisineValue: json['cuisine_value'] as String,
      action: SwipeAction.values.firstWhere(
        (a) => a.wire == raw,
        orElse: () => SwipeAction.skipped,
      ),
      swipedAt: json['swiped_at'] == null
          ? null
          : DateTime.tryParse(json['swiped_at'] as String),
    );
  }
}