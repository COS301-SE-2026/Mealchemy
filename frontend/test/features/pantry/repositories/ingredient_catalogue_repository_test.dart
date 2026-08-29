import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/pantry/repositories/ingredient_catalogue_repository.dart';

void main() {
  late Dio dio;
  late IngredientCatalogueRepository repository;
  late RequestOptions? lastRequest;

  setUp(() {
    dio = Dio();
    lastRequest = null;

    //fake backend response
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          lastRequest = options;

          final isSearchRequest =
              options.path == '/api/ingredient-catalogue/search';
          final isCategoriesRequest = options.path == '/api/categories';
          final isImportRequest =
              options.path == '/api/ingredient-catalogue/add-external';

          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: isImportRequest
                  ? {
                      'ing_id': 25,
                      'name': 'Kimchi',
                      'category': 'Vegetables',
                    }
                  : isCategoriesRequest
                      ? [
                          {
                            'category_id': 1,
                            'name': 'Baked Products',
                          },
                          {
                            'category_id': 4,
                            'name': 'Dairy',
                          },
                        ]
                      : isSearchRequest
                          ? [
                              {
                                'ing_id': 10,
                                'name': 'Milk',
                                'category': 'Dairy',
                                'source_id': null,
                                'source_api': null,
                              },
                              {
                                'ing_id': null,
                                'name': 'Kimchi',
                                'category': null,
                                'source_id': '2710077',
                                'source_api': 'USDA',
                              },
                            ]
                          : [
                              {
                                'ing_id': 10,
                                'name': 'Milk',
                                'category': 'Dairy',
                              },
                              {
                                'ing_id': '11',
                                'name': 'Chicken Breast',
                                'category': 'poultry',
                              },
                            ],
            ),
          );
        },
      ),
    );

    repository = IngredientCatalogueRepository(dio);
  });

  test('getAllIngredients maps backend catalogue JSON', () async {
    final ingredients = await repository.getAllIngredients();

    expect(lastRequest?.path, '/api/ingredient-catalogue');
    expect(ingredients, hasLength(2));

    expect(ingredients.first.ingId, 10);
    expect(ingredients.first.name, 'Milk');
    expect(ingredients.first.category, 'Dairy');

    //also proves string ids don't break
    expect(ingredients.last.ingId, 11);
    expect(ingredients.last.name, 'Chicken Breast');
    expect(ingredients.last.category, 'poultry');
  });

  test('searchIngredients maps local and USDA search results', () async {
    final ingredients = await repository.searchIngredients(' milk ');

    expect(lastRequest?.path, '/api/ingredient-catalogue/search');
    expect(lastRequest?.queryParameters['q'], 'milk');
    expect(ingredients, hasLength(2));

    final localIngredient = ingredients.first;

    expect(localIngredient.ingId, 10);
    expect(localIngredient.name, 'Milk');
    expect(localIngredient.category, 'Dairy');
    expect(localIngredient.sourceId, isNull);
    expect(localIngredient.sourceApi, isNull);
    expect(localIngredient.requiresImport, isFalse);

    final externalIngredient = ingredients.last;

    expect(externalIngredient.ingId, isNull);
    expect(externalIngredient.name, 'Kimchi');
    expect(externalIngredient.category, isNull);
    expect(externalIngredient.sourceId, '2710077');
    expect(externalIngredient.sourceApi, 'USDA');
    expect(externalIngredient.requiresImport, isTrue);
  });

  test('searchIngredients returns empty list for blank query', () async {
    final ingredients = await repository.searchIngredients('   ');

    expect(lastRequest, isNull);
    expect(ingredients, isEmpty);
  });

  test('getCategories maps backend category options', () async {
    final categories = await repository.getCategories();

    expect(lastRequest?.path, '/api/categories');
    expect(categories, hasLength(2));

    expect(categories.first.categoryId, 1);
    expect(categories.first.name, 'Baked Products');

    expect(categories.last.categoryId, 4);
    expect(categories.last.name, 'Dairy');
  });

  test('importExternalIngredient posts source and nullable category id',
      () async {
    final ingredient = await repository.importExternalIngredient(
      sourceId: '2710077',
    );

    expect(lastRequest?.method, 'POST');
    expect(
      lastRequest?.path,
      '/api/ingredient-catalogue/add-external',
    );
    expect(lastRequest?.data, {
      'source_id': '2710077',
      'category_id': null,
    });

    expect(ingredient.ingId, 25);
    expect(ingredient.name, 'Kimchi');
    expect(ingredient.category, 'Vegetables');
    expect(ingredient.requiresImport, isFalse);
  });
}
