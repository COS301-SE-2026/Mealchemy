import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/models/cook_session.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';

void main() {
  final saved = CookSession(
    recipeId: 7,
    recipeTitle: 'Pasta',
    stepIndex: 1,
    stepNumber: 2,
    stepId: 22,
    stepText: 'Add sauce.',
    stepCount: 2,
    savedAt: DateTime.utc(2026, 9, 13),
  );

  test('round-trips a cooking session', () {
    final restored = CookSession.fromJson(saved.toJson());
    expect(restored.recipeId, 7);
    expect(restored.stepId, 22);
    expect(restored.savedAt, saved.savedAt);
  });

  test('finds a step by stable identity after reordering', () {
    const steps = [
      RecipeStep(stepId: 22, stepNr: 1, content: 'Add sauce.'),
      RecipeStep(stepId: 11, stepNr: 2, content: 'Boil pasta.'),
    ];
    expect(saved.matchingStepIndex(steps), 0);
  });

  test('rejects a changed step even when its ID remains', () {
    const steps = [
      RecipeStep(stepId: 22, stepNr: 2, content: 'Add more sauce.'),
    ];
    expect(saved.matchingStepIndex(steps), isNull);
  });

  test('matches an ID-less step only at its original position', () {
    final withoutId = CookSession.fromJson({...saved.toJson(), 'stepId': null});
    const steps = [
      RecipeStep(stepNr: 1, content: 'Boil pasta.'),
      RecipeStep(stepNr: 2, content: 'Add sauce.'),
    ];
    expect(withoutId.matchingStepIndex(steps), 1);
    expect(withoutId.matchingStepIndex(steps.reversed.toList()), isNull);
  });
}
