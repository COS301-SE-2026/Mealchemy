import '../../recipe/models/recipe.dart';

class MealPlan {
  final int planId;
  final int vaultId;

  const MealPlan({required this.planId, required this.vaultId});

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      planId: json['planId'] as int,
      vaultId: json['vaultId'] as int,
    );
  }
}

class MealSuggestion {
  final Recipe recipe;
  final String cuisineType;
  final Map<String, dynamic> scoreBreakdown;

  const MealSuggestion({
    required this.recipe,
    required this.cuisineType,
    required this.scoreBreakdown,
  });

  factory MealSuggestion.fromJson(Map<String, dynamic> json) {
    final recipe = Recipe.fromJson(json['recipe'] as Map<String, dynamic>);
    return MealSuggestion(
      recipe: recipe,
      cuisineType: json['cuisineType'] as String? ?? recipe.cuisineType ?? 'OTHER',
      scoreBreakdown: Map<String, dynamic>.from(json['scoreBreakdown'] as Map? ?? {}),
    );
  }
}