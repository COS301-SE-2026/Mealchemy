import 'package:mealchemy/features/recipe/models/recipe.dart';
import 'signal_scores.dart';
// A single recommended recipe from the discovery engine.
class Recommendation {
  final int recipeId;
  final String cuisineType;
  final double score;
  final SignalScores scoreBreakdown;
  final int pantryGapCount;
  final List<String> missingIngredients;
  final Recipe recipe;

  const Recommendation({
    required this.recipeId,
    required this.cuisineType,
    required this.score,
    required this.scoreBreakdown,
    required this.pantryGapCount,
    required this.missingIngredients,
    required this.recipe,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      recipeId: json['recipeId'] as int,
      cuisineType: json['cuisineType'] as String,
      score: (json['score'] as num).toDouble(),
      scoreBreakdown:
          SignalScores.fromJson(json['scoreBreakdown'] as Map<String, dynamic>),
      pantryGapCount: (json['pantryGapCount'] as int?) ?? 0,
      missingIngredients:
          (json['missingIngredients'] as List<dynamic>?)?.cast<String>() ??
              const [],
      recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
    );
  }

  int get matchPercent => (score * 100).round();
}