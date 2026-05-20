import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/pantry/providers/pantry_provider.dart';
import 'package:mealchemy/features/pantry/repositories/mock_pantry_repository.dart';
import 'package:mealchemy/features/pantry/widgets/pantry_item_card.dart';

void main() {
  test('pantryRepositoryProvider uses mock repository', () {
    //create Riverpod provider container for isolated testing
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final repository = container.read(pantryRepositoryProvider);

    expect(repository, isA<MockPantryRepository>());
  });

  test('pantry providers expose mock pantry data', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final summary = await container.read(pantrySummaryProvider.future);
    final filters = await container.read(pantryFiltersProvider.future);
    final ingredients = await container.read(pantryIngredientsProvider.future);
    final categories = await container.read(ingredientCategoriesProvider.future);

    expect(summary.totalItems, 42);
    expect(filters.first.label, 'All');
    expect(ingredients.first.name, 'Chicken Breast');
    expect(categories, contains('produce'));
  });

  test('selectFilter updates selected pantry filter', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(pantryStateProvider.future);

    final notifier = container.read(pantryStateProvider.notifier);
    notifier.selectFilter('Dairy');

    final pantryState = container.read(pantryStateProvider).value!;

    expect(pantryState.selectedFilter, 'Dairy');
  });

  test('updateSearchQuery trims and stores query', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(pantryStateProvider.future);

    final notifier = container.read(pantryStateProvider.notifier);
    notifier.updateSearchQuery('  milk  ');

    final pantryState = container.read(pantryStateProvider).value!;

    expect(pantryState.searchQuery, 'milk');
  });

  test('clearSearch resets search query', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(pantryStateProvider.future);

    final notifier = container.read(pantryStateProvider.notifier);
    notifier.updateSearchQuery('salmon');
    notifier.clearSearch();

    final pantryState = container.read(pantryStateProvider).value!;

    expect(pantryState.searchQuery, isEmpty);
  });

  test('markOutOfStock changes ingredient status to expired', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(pantryStateProvider.future);

    final notifier = container.read(pantryStateProvider.notifier);
    notifier.markOutOfStock('Chicken Breast');

    final pantryState = container.read(pantryStateProvider).value!;
    final ingredient = pantryState.ingredients.firstWhere(
      (item) => item.name == 'Chicken Breast',
    );

    expect(ingredient.status, PantryItemStatus.expired);
  });

  test('removeIngredient removes ingredient from local pantry list', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(pantryStateProvider.future);

    final notifier = container.read(pantryStateProvider.notifier);
    notifier.removeIngredient('Chicken Breast');

    final pantryState = container.read(pantryStateProvider).value!;

    expect(
      pantryState.ingredients.any((item) => item.name == 'Chicken Breast'),
      isFalse,
    );
  });

  test('addIngredient adds manual ingredient to local pantry list', () async {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  await container.read(pantryStateProvider.future);

  final notifier = container.read(pantryStateProvider.notifier);
  notifier.addIngredient(
    name: 'Brown Rice',
    quantity: '500',
    unit: 'g',
    category: 'grains',
    isOutOfStock: false,
  );

  final pantryState = container.read(pantryStateProvider).value!;
  final ingredient = pantryState.ingredients.firstWhere(
    (item) => item.name == 'Brown Rice',
  );

  expect(ingredient.details, '500g • Manual entry');
  expect(ingredient.category, 'Other');
  expect(ingredient.status, PantryItemStatus.fresh);
});
}