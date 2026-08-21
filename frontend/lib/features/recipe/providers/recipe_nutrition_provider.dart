import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/recipe_nutrition.dart';
import '../repositories/mock_recipe_nutrition_repository.dart';
import '../repositories/recipe_nutrition_repository.dart';

//defaults to mock data until backend nutrition endpoint
final recipeNutritionRepositoryProvider =
    Provider<RecipeNutritionRepository>((ref) {
  return MockRecipeNutritionRepository();
});

//loads complete nutrition response for 1 recipe
final recipeNutritionProvider =
    FutureProvider.family<RecipeNutrition, int>((ref, recipeId) {
  final repository = ref.watch(recipeNutritionRepositoryProvider);
  return repository.getRecipeNutrition(recipeId);
});
