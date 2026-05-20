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
      stepId: json['step_id'] as int,
      recipeId: json['recipe_id'] as int,
      stepNr: json['step_nr'] as int,
      content: json['content'] as String,
    );
  }
}
