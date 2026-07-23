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

          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: [
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

  test('searchIngredients calls search endpoint with q parameter', () async {
    final ingredients = await repository.searchIngredients(' milk ');

    expect(lastRequest?.path, '/api/ingredient-catalogue/search');
    expect(lastRequest?.queryParameters['q'], 'milk');
    expect(ingredients, hasLength(2));
  });

  test('searchIngredients returns empty list for blank query', () async {
    final ingredients = await repository.searchIngredients('   ');

    expect(lastRequest, isNull);
    expect(ingredients, isEmpty);
  });
}
