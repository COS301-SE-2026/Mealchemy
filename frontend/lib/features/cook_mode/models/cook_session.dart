import '../../recipe/models/recipe_step.dart';

class CookSession {
  const CookSession({
    required this.recipeId,
    required this.recipeTitle,
    required this.stepIndex,
    required this.stepNumber,
    required this.stepText,
    required this.stepCount,
    required this.savedAt,
    this.stepId,
  });

  final int recipeId;
  final String recipeTitle;
  final int stepIndex;
  final int stepNumber;
  final int? stepId;
  final String stepText;
  final int stepCount;
  final DateTime savedAt;

  int? matchingStepIndex(List<RecipeStep> steps) {
    if (stepId != null) {
      for (var index = 0; index < steps.length; index++) {
        if (steps[index].stepId == stepId && steps[index].content == stepText) {
          return index;
        }
      }
      return null;
    }

    if (stepIndex < 0 || stepIndex >= steps.length) return null;
    final step = steps[stepIndex];
    return step.stepNr == stepNumber && step.content == stepText
        ? stepIndex
        : null;
  }

  factory CookSession.fromJson(Map<String, dynamic> json) => CookSession(
        recipeId: json['recipeId'] as int,
        recipeTitle: json['recipeTitle'] as String,
        stepIndex: json['stepIndex'] as int,
        stepNumber: json['stepNumber'] as int,
        stepId: json['stepId'] as int?,
        stepText: json['stepText'] as String,
        stepCount: json['stepCount'] as int,
        savedAt: DateTime.parse(json['savedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'recipeId': recipeId,
        'recipeTitle': recipeTitle,
        'stepIndex': stepIndex,
        'stepNumber': stepNumber,
        'stepId': stepId,
        'stepText': stepText,
        'stepCount': stepCount,
        'savedAt': savedAt.toIso8601String(),
      };
}
