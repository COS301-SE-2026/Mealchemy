//one numbered step in a recipe
//mirrors recipe_steps table
class RecipeStep {
  final int stepId;
  final int recipeId;
  final int stepNr;
  final String content;

  const RecipeStep({
    required this.stepId,
    required this.recipeId,
    required this.stepNr,
    required this.content,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      stepId: json['stepId'] as int,
      recipeId: json['recipeId'] as int,
      stepNr: json['stepNr'] as int,
      content: json['content'] as String,
    );
  }
  Map<String, dynamic> toJson() => {
        'stepNr': stepNr,
        'content': content,
      };
}
