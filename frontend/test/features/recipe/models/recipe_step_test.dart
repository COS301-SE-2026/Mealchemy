import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';

void main() {
  group('RecipeStep.fromJson', () {
    test('parses a step payload with camelCase keys', () {
      final json = <String, dynamic>{
        'stepId': 201,
        'recipeId': 1,
        'stepNr': 1,
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
        'stepId': 212,
        'recipeId': 5,
        'stepNr': 12,
        'content': 'Final step content.',
      };

      final step = RecipeStep.fromJson(json);

      expect(step.stepNr, 12);
    });
    test('leaves stepId when absent (unsaved row)', () {
      final json = <String, dynamic>{
        'stepNr': 1,
        'content': 'Mix the dry ingredients.',
      };

      final step = RecipeStep.fromJson(json);

      expect(step.stepId, isNull);
      expect(step.recipeId, isNull);
      expect(step.stepNr, 1);
      expect(step.content, 'Mix the dry ingredients.');
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

    test('builds an unsaved step with only stepNr and content', () {
      const step = RecipeStep(stepNr: 2, content: 'Simmer for ten minutes.');

      expect(step.stepId, isNull);
      expect(step.recipeId, isNull);
      expect(step.stepNr, 2);
    });
  });
  group('RecipeStep.toJson', () {
    test('emits the RecipeStepRequest shape (stepNr + content only)', () {
      const step = RecipeStep(stepNr: 3, content: 'Fold in the parmesan.');
      final json = step.toJson();
      expect(json, {'stepNr': 3, 'content': 'Fold in the parmesan.'});
      expect(json.containsKey('stepId'), isFalse);
      expect(json.containsKey('recipeId'), isFalse);
    });
  });
}
