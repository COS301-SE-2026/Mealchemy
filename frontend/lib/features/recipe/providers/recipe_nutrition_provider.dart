import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/api_service_provider.dart';
import '../models/recipe_nutrition.dart';
import '../repositories/api_recipe_nutrition_repository.dart';
import '../repositories/mock_recipe_nutrition_repository.dart';
import '../repositories/recipe_nutrition_repository.dart';
import 'recipe_provider.dart';

//real nutritional calculator API repository
final remoteRecipeNutritionRepositoryProvider =
    Provider<RecipeNutritionRepository>((ref) {
  return ApiRecipeNutritionRepository(
    ref.read(dioProvider),
  );
});

//uses the same mock/API setting as the rest of the Recipe feature
final recipeNutritionRepositoryProvider =
    Provider<RecipeNutritionRepository>((ref) {
  if (ref.watch(mockRecipeEnabledProvider)) {
    return MockRecipeNutritionRepository();
  }

  return ref.watch(remoteRecipeNutritionRepositoryProvider);
});

//loads the complete nutrition response for one recipe
final recipeNutritionProvider =
    FutureProvider.family<RecipeNutrition, int>((ref, recipeId) {
  final repository = ref.watch(
    recipeNutritionRepositoryProvider,
  );

  return repository.getRecipeNutrition(recipeId);
});
