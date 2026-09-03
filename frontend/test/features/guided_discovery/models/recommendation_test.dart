import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/guided_discovery/models/recommendation.dart';

void main() {
  Map<String, dynamic> recipeJson() => {
        'recipeId': 7,
        'ownerId': 8,
        'title': 'Hummus Bowl',
        'description': 'A tasty bowl.',
        'cuisineType': 'MEDITERRANEAN',
        'prepTimeMins': 10,
        'cookingTimeMins': 0,
        'servingSize': 2,
        'photoUrl': null,
        'videoUrl': null,
        'externalUrl': null,
        'isCommunityPublished': true,
        'createdAt': '2026-09-02T21:19:36.844531Z',
        'updatedAt': '2026-09-02T21:19:36.844540Z',
      };

  Map<String, dynamic> recommendationJson() => {
        'recipeId': 7,
        'cuisineType': 'MEDITERRANEAN',
        'score': 0.87,
        'scoreBreakdown': {
          'pantry_match': 0.9,
          'cuisine': 0.8,
          'nutrition': 0.5,
          'freshness': 0.3,
          'novelty': 1.0,
        },
        'pantryGapCount': 1,
        'missingIngredients': ['parmesan'],
        'recipe': recipeJson(),
      };

  group('Recommendation.fromJson', () {
    test('parses all fields including the nested recipe and scores', () {
      final rec = Recommendation.fromJson(recommendationJson());
      expect(rec.recipeId, 7);
      expect(rec.cuisineType, 'MEDITERRANEAN');
      expect(rec.score, 0.87);
      expect(rec.pantryGapCount, 1);
      expect(rec.missingIngredients, ['parmesan']);
      expect(rec.scoreBreakdown.pantryMatch, 0.9);
      expect(rec.recipe.recipeId, 7);
      expect(rec.recipe.title, 'Hummus Bowl');
    });

    test('coerces an integer score to double', () {
      final json = recommendationJson()..['score'] = 1;
      final rec = Recommendation.fromJson(json);
      expect(rec.score, 1.0);
    });

    test('defaults pantryGapCount to 0 when  absent', () {
      final json = recommendationJson()..remove('pantryGapCount');
      final rec = Recommendation.fromJson(json);
      expect(rec.pantryGapCount, 0);
    });

    test('defaults missingIngredients to empty when absent', () {
      final json = recommendationJson()..remove('missingIngredients');
      final rec = Recommendation.fromJson(json);

      expect(rec.missingIngredients, isEmpty);
    });
  });

  group('matchPercent', () {
    test('rounds score to a whole percent', () {
      final rec = Recommendation.fromJson(
        recommendationJson()..['score'] = 0.876,
      );
      expect(rec.matchPercent, 88);
    });
  });
}