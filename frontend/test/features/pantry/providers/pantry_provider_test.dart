import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/pantry/providers/pantry_provider.dart';
import 'package:mealchemy/features/pantry/repositories/mock_pantry_repository.dart';
import 'package:mealchemy/features/pantry/widgets/pantry_item_card.dart';

void main() {
  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        pantryRepositoryProvider.overrideWithValue(MockPantryRepository()),
      ],
    );

    addTearDown(container.dispose);
    return container;
  }

  // test('pantryRepositoryProvider uses mock repository', () {
  //   //create Riverpod provider container for isolated testing
  //   final container = ProviderContainer();
  //   addTearDown(container.dispose);

  //   final repository = container.read(pantryRepositoryProvider);

  //   expect(repository, isA<MockPantryRepository>());
  // });

  test('pantry providers expose mock pantry data', () async {
    final container = createContainer();

    final summary = await container.read(pantrySummaryProvider.future);
    final filters = await container.read(pantryFiltersProvider.future);
    final ingredients = await container.read(pantryIngredientsProvider.future);
    final categories =
        await container.read(ingredientCategoriesProvider.future);

    expect(summary.totalItems, 42);
    expect(filters.first.label, 'All');
    expect(ingredients.first.name, 'Chicken Breast');
    expect(categories, contains('produce'));
  });

  test('selectFilter updates selected pantry filter', () async {
    final container = createContainer();

    await container.read(pantryStateProvider.future);

    final notifier = container.read(pantryStateProvider.notifier);
    notifier.selectFilter('Dairy');

    final pantryState = container.read(pantryStateProvider).value!;

    expect(pantryState.selectedFilter, 'Dairy');
  });

  test('updateSearchQuery trims and stores query', () async {
    final container = createContainer();

    await container.read(pantryStateProvider.future);

    final notifier = container.read(pantryStateProvider.notifier);
    notifier.updateSearchQuery('  milk  ');

    final pantryState = container.read(pantryStateProvider).value!;

    expect(pantryState.searchQuery, 'milk');
  });

  test('clearSearch resets search query', () async {
    final container = createContainer();

    await container.read(pantryStateProvider.future);

    final notifier = container.read(pantryStateProvider.notifier);
    notifier.updateSearchQuery('salmon');
    notifier.clearSearch();

    final pantryState = container.read(pantryStateProvider).value!;

    expect(pantryState.searchQuery, isEmpty);
  });

  test('markOutOfStock changes ingredient status to expired', () async {
    final container = createContainer();

    await container.read(pantryStateProvider.future);

    final notifier = container.read(pantryStateProvider.notifier);
    notifier.markOutOfStock('Chicken Breast');

    final pantryState = container.read(pantryStateProvider).value!;
    final ingredient = pantryState.ingredients.firstWhere(
      (item) => item.name == 'Chicken Breast',
    );

    expect(ingredient.status, PantryItemStatus.expired);
  });

  test('removeIngredient deletes ingredient by pantry id', () async {
    final container = createContainer();

    await container.read(pantryStateProvider.future);

    final pantryStateBefore = container.read(pantryStateProvider).value!;
    final ingredientToDelete = pantryStateBefore.ingredients.first;

    final notifier = container.read(pantryStateProvider.notifier);
    await notifier.removeIngredient(ingredientToDelete.pIngredientId!);

    final pantryStateAfter = container.read(pantryStateProvider).value!;

    expect(
      pantryStateAfter.ingredients.any(
        (item) => item.pIngredientId == ingredientToDelete.pIngredientId,
      ),
      isFalse,
    );
  });

  test('addIngredient adds repository-created ingredient to pantry list',
      () async {
    final container = createContainer();

    await container.read(pantryStateProvider.future);

    final notifier = container.read(pantryStateProvider.notifier);
    await notifier.addIngredient(
      ingId: 44,
      quantity: '500',
      unit: 'g',
    );

    final pantryState = container.read(pantryStateProvider).value!;
    final ingredient = pantryState.ingredients.firstWhere(
      (item) => item.ingId == 44,
    );

    //the mock repo now behaves like the backend-shaped API response
    expect(ingredient.pIngredientId, 999);
    expect(ingredient.name, 'Mock ingredient');
    expect(ingredient.details, '500g • Manual entry');
    expect(ingredient.category, 'Other');
    expect(ingredient.status, PantryItemStatus.fresh);
  });

  test('updateIngredient replaces pantry item with repository result',
      () async {
    final container = createContainer();

    await container.read(pantryStateProvider.future);

    final pantryStateBefore = container.read(pantryStateProvider).value!;
    final ingredientToUpdate = pantryStateBefore.ingredients.first;

    final notifier = container.read(pantryStateProvider.notifier);
    await notifier.updateIngredient(
      pIngredientId: ingredientToUpdate.pIngredientId!,
      ingId: ingredientToUpdate.ingId!,
      quantity: '123',
      unit: 'g',
    );

    final pantryStateAfter = container.read(pantryStateProvider).value!;
    final updatedIngredient = pantryStateAfter.ingredients.firstWhere(
      (item) => item.pIngredientId == ingredientToUpdate.pIngredientId,
    );

    //provider swaps in backend-shaped updated pantry row
    expect(updatedIngredient.ingId, ingredientToUpdate.ingId);
    expect(updatedIngredient.details, '123g • Pantry');
    expect(updatedIngredient.quantity, '123');
    expect(updatedIngredient.unit, 'g');
  });
}
