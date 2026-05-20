import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/pantry/providers/pantry_provider.dart';
import 'package:mealchemy/features/pantry/repositories/mock_pantry_repository.dart';

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
}