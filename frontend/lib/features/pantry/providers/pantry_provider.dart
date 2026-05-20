// Holds the user's pantry item list.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../models/pantry_ingredient.dart';
import '../models/pantry_summary.dart';
import '../repositories/api_pantry_repository.dart';
import '../repositories/mock_pantry_repository.dart';
import '../repositories/pantry_repository.dart';
import '../widgets/pantry_item_card.dart';

//selects mock/API repo
final pantryRepositoryProvider = Provider<PantryRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockPantryRepository();
  }

  return ApiPantryRepository();
});

//editable pantry screen
final pantryStateProvider = AsyncNotifierProvider<PantryNotifier, PantryState>(
  PantryNotifier.new,
);

class PantryNotifier extends AsyncNotifier<PantryState> {
  late final PantryRepository _repository;

  @override
  Future<PantryState> build() async {
    _repository = ref.watch(pantryRepositoryProvider);

    final summary = await _repository.getPantrySummary();
    final filters = await _repository.getPantryFilters();
    final ingredients = await _repository.getPantryIngredients();
    final categories = await _repository.getIngredientCategories();

    return PantryState(
      summary: summary,
      filters: filters,
      ingredients: ingredients,
      categories: categories,
    );
  }

  //filtering
  void selectFilter(String filterLabel) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(selectedFilter: filterLabel));
  }

  //searching
  void updateSearchQuery(String query) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(searchQuery: query.trim()));
  }

  //clears search
  void clearSearch() {
    updateSearchQuery('');
  }

  //out of stock
  void markOutOfStock(String ingredientName) {
    final current = state.valueOrNull;
    if (current == null) return;

    final updatedIngredients = current.ingredients.map((ingredient) {
      if (ingredient.name != ingredientName) return ingredient;
      return ingredient.copyWith(status: PantryItemStatus.expired);
    }).toList();

    state = AsyncData(current.copyWith(ingredients: updatedIngredients));
  }

  //removes ingredient from pantry list
  void removeIngredient(String ingredientName) {
    final current = state.valueOrNull;
    if (current == null) return;

    final updatedIngredients = current.ingredients
        .where((ingredient) => ingredient.name != ingredientName)
        .toList();

    state = AsyncData(current.copyWith(ingredients: updatedIngredients));
  }
}

final pantrySummaryProvider = FutureProvider<PantrySummary>((ref) async {
  final pantryState = await ref.watch(pantryStateProvider.future);
  return pantryState.summary;
});

final pantryFiltersProvider = FutureProvider<List<PantryFilter>>((ref) async {
  final pantryState = await ref.watch(pantryStateProvider.future);
  return pantryState.filters;
});

final pantryIngredientsProvider =
    FutureProvider<List<PantryIngredient>>((ref) async {
  final pantryState = await ref.watch(pantryStateProvider.future);
  return pantryState.ingredients;
});

final ingredientCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final pantryState = await ref.watch(pantryStateProvider.future);
  return pantryState.categories;
});