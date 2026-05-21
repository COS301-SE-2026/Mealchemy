import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';

void main() {
  group('RecipeStep.fromJson', () {
    test('parses a step payload with snake_case keys', () {
      final json = <String, dynamic>{
        'step_id': 201,
        'recipe_id': 1,
        'step_nr': 1,
        'content': 'Warm the stock and steep the saffron.',
      };

      final step = RecipeStep.fromJson(json);

      expect(step.stepId, 201);
      expect(step.recipeId, 1);
      expect(step.stepNr, 1);
      expect(step.content, 'Warm the stock and steep the saffron.');
    });

    test('parses a step with two-digit step number', () {
      final json = <String, dynamic>{
        'step_id': 212,
        'recipe_id': 5,
        'step_nr': 12,
        'content': 'Final step content.',
      };

      final step = RecipeStep.fromJson(json);

      expect(step.stepNr, 12);
    });
  });

  group('RecipeStep constructor', () {
    test('builds a RecipeStep from named args', () {
      const step = RecipeStep(
        stepId: 1,
        recipeId: 1,
        stepNr: 1,
        content: 'Mix dry ingredients.',
      );

      expect(step.stepId, 1);
      expect(step.recipeId, 1);
      expect(step.stepNr, 1);
      expect(step.content, 'Mix dry ingredients.');
    });
  });
}
