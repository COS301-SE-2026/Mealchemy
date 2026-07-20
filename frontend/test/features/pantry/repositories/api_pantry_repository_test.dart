import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/pantry/repositories/api_pantry_repository.dart';
import 'package:mealchemy/features/pantry/widgets/pantry_item_card.dart';

void main() {
  late ApiPantryRepository repository;

  setUp(() {
    final dio = Dio();

    //keep the repo test fast and offline
    //without calling the real backend
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: [
                {
                  'p_ingredient_id': 1,
                  'ing_id': 2,
                  'name': 'Chicken Breast',
                  'category': 'poultry',
                  'quantity': 800,
                  'unit': 'g',
                  'created_at': '2026-07-19T10:00:00Z',
                  'updated_at': '2026-07-19T10:00:00Z',
                },
                {
                  'p_ingredient_id': 2,
                  'ing_id': 3,
                  'name': 'Full Cream Milk',
                  'category': 'dairy',
                  'quantity': 1,
                  'unit': 'L',
                  'created_at': '2026-07-19T10:00:00Z',
                  'updated_at': '2026-07-19T10:00:00Z',
                },
              ],
            ),
          );
        },
      ),
    );

    repository = ApiPantryRepository(dio);
  });

  test('getPantryIngredients maps backend pantry JSON into UI ingredients',
      () async {
    final ingredients = await repository.getPantryIngredients();

    expect(ingredients, hasLength(2));

    //first item keeps both the UI display data and backend ids
    expect(ingredients.first.pIngredientId, 1);
    expect(ingredients.first.ingId, 2);
    expect(ingredients.first.name, 'Chicken Breast');
    expect(ingredients.first.details, '800g • Pantry');
    expect(ingredients.first.category, 'Proteins');
    expect(ingredients.first.status, PantryItemStatus.fresh);
    expect(ingredients.first.quantity, '800');
    expect(ingredients.first.unit, 'g');

    //second item proves mapper handles another category/unit too
    expect(ingredients.last.pIngredientId, 2);
    expect(ingredients.last.ingId, 3);
    expect(ingredients.last.name, 'Full Cream Milk');
    expect(ingredients.last.details, '1L • Pantry');
    expect(ingredients.last.category, 'Dairy');
    expect(ingredients.last.quantity, '1');
    expect(ingredients.last.unit, 'L');
  });

  test('getPantrySummary builds summary values from API pantry items',
      () async {
    final summary = await repository.getPantrySummary();

    expect(summary.totalItems, 2);
    expect(summary.freshnessPercent, 100);
    expect(summary.categoryCount, 2);
    expect(summary.optimizationPercent, 72);
  });

  test('getPantryFilters builds filter counts from API pantry items', () async {
    final filters = await repository.getPantryFilters();

    expect(filters.map((filter) => filter.label),
        containsAll(['All', 'Proteins', 'Dairy']));
    expect(filters.first.label, 'All');
    expect(filters.first.count, 2);
  });

  test(
      'getIngredientCategories returns sorted categories from API pantry items',
      () async {
    final categories = await repository.getIngredientCategories();

    expect(categories, ['Dairy', 'Proteins']);
  });
}
