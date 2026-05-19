import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/pantry/repositories/api_pantry_repository.dart';

void main() {
  //throw
  test('ApiPantryRepository throws for summary until API is implemented', () {
    //create repo instance
    final repository = ApiPantryRepository();

    expect(repository.getPantrySummary, throwsA(isA<UnimplementedError>()));
  });

  test('ApiPantryRepository throws for filters until API is implemented', () {
    final repository = ApiPantryRepository();

    //ensure it fails (not returning invalid data)
    expect(repository.getPantryFilters, throwsA(isA<UnimplementedError>()));
  });

  test('ApiPantryRepository throws for ingredients until API is implemented', () {
    final repository = ApiPantryRepository();

    expect(repository.getPantryIngredients, throwsA(isA<UnimplementedError>()));
  });

  test('ApiPantryRepository throws for categories until API is implemented', () {
    final repository = ApiPantryRepository();

    expect(repository.getIngredientCategories, throwsA(isA<UnimplementedError>()));
  });
}