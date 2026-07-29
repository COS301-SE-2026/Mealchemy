// Holds the user's pantry item list.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../models/pantry_ingredient.dart';
import '../models/pantry_summary.dart';
import '../repositories/api_pantry_repository.dart';
import '../repositories/mock_pantry_repository.dart';
import '../repositories/pantry_repository.dart';
import '../widgets/pantry_item_card.dart';
import '../../../core/providers/api_service_provider.dart';
import '../repositories/ingredient_catalogue_repository.dart';

//selects mock/API repo
final pantryRepositoryProvider = Provider<PantryRepository>((ref) {
  if (AppConfig.mockPantry) {
    return MockPantryRepository();
  }

  return ApiPantryRepository(ref.read(dioProvider));
});

//gives screens access to ingredient catalogue search
final ingredientCatalogueRepositoryProvider =
    Provider<IngredientCatalogueRepository>((ref) {
  return IngredientCatalogueRepository(ref.read(dioProvider));
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

  //adds ingredient to pantry through active repo
  Future<void> addIngredient({
    required int ingId,
    required String quantity,
    required String unit,
  }) async {
    final current = state.valueOrNull;
    final cleanedQuantity = quantity.trim();
    final cleanedUnit = unit.trim();

    if (current == null || cleanedQuantity.isEmpty || cleanedUnit.isEmpty) {
      return;
    }

    final createdIngredient = await _repository.addPantryIngredient(
      ingId: ingId,
      quantity: cleanedQuantity,
      unit: cleanedUnit,
    );

    //add backend created item to current screen
    state = AsyncData(
      current.copyWith(
        ingredients: [...current.ingredients, createdIngredient],
      ),
    );
  }

  //removes ingredient from backend first, then from the local screen list
  Future<void> removeIngredient(int pIngredientId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    await _repository.deletePantryIngredient(pIngredientId);

    final updatedIngredients = current.ingredients
        .where((ingredient) => ingredient.pIngredientId != pIngredientId)
        .toList();

    state = AsyncData(current.copyWith(ingredients: updatedIngredients));
  }

  //updates an existing pantry row without needing a new screen yet
  Future<void> updateIngredient({
    required int pIngredientId,
    required int ingId,
    required String quantity,
    required String unit,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updatedIngredient = await _repository.updatePantryIngredient(
      pIngredientId: pIngredientId,
      ingId: ingId,
      quantity: quantity,
      unit: unit,
    );

    final updatedIngredients = current.ingredients.map((ingredient) {
      if (ingredient.pIngredientId != pIngredientId) {
        return ingredient;
      }

      return updatedIngredient;
    }).toList();

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
