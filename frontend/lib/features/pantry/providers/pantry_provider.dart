// Holds the user's pantry item list.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../models/pantry_ingredient.dart';
import '../models/pantry_summary.dart';
import '../repositories/api_pantry_repository.dart';
import '../repositories/mock_pantry_repository.dart';
import '../repositories/pantry_repository.dart';

//selects mock/API repo
final pantryRepositoryProvider = Provider<PantryRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockPantryRepository();
  }

  return ApiPantryRepository();
});

//pantry summaries
final pantrySummaryProvider = FutureProvider<PantrySummary>((ref) {
  final repository = ref.watch(pantryRepositoryProvider);
  return repository.getPantrySummary();
});

//pantry filtering
final pantryFiltersProvider = FutureProvider<List<PantryFilter>>((ref) {
  final repository = ref.watch(pantryRepositoryProvider);
  return repository.getPantryFilters();
});

//pantry ingredients
final pantryIngredientsProvider = FutureProvider<List<PantryIngredient>>((ref) {
  final repository = ref.watch(pantryRepositoryProvider);
  return repository.getPantryIngredients();
});

//ingredient categories (user adds)
final ingredientCategoriesProvider = FutureProvider<List<String>>((ref) {
  final repository = ref.watch(pantryRepositoryProvider);
  return repository.getIngredientCategories();
});
