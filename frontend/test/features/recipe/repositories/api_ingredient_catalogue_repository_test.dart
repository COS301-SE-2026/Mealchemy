import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/ingredients/repositories/api_ingredient_catalogue_repository.dart';
import 'package:mealchemy/features/ingredients/repositories/ingredient_catalogue_repository.dart';

void main() {
  late Dio dio;
  late ApiIngredientCatalogueRepository repository;
  late RequestOptions? lastRequest;

  setUp(() {
    dio = Dio();
    lastRequest = null;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          lastRequest = options;

          if (options.path == '/api/categories') {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: [
                  {
                    'category_id': 1,
                    'name': 'Baked Products',
                  },
                  {
                    'category_id': 4,
                    'name': 'Dairy',
                  },
                ],
              ),
            );
            return;
          }

          if (options.path == '/api/ingredient-catalogue/add-external') {
            final requestData = options.data;

            final needsCategory = requestData is Map &&
                requestData['source_id'] == 'requires-category' &&
                requestData['category_id'] == null;

            if (needsCategory) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 422,
                    data: {
                      'source_id': 'requires-category',
                      'name': 'Kimchi',
                    },
                  ),
                  type: DioExceptionType.badResponse,
                ),
              );
              return;
            }
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'ing_id': 25,
                  'name': 'Kimchi',
                  'category': 'Vegetables',
                },
              ),
            );
            return;
          }

          handler.reject(
            DioException(
              requestOptions: options,
              error: 'Unexpected test request.',
            ),
          );
        },
      ),
    );

    repository = ApiIngredientCatalogueRepository(dio);
  });

  test('getCategories maps backend category options', () async {
    final categories = await repository.getCategories();

    expect(lastRequest?.method, 'GET');
    expect(lastRequest?.path, '/api/categories');
    expect(categories, hasLength(2));
    expect(categories.first.categoryId, 1);
    expect(categories.first.name, 'Baked Products');
    expect(categories.last.categoryId, 4);
    expect(categories.last.name, 'Dairy');
  });

  test('importExternalIngredient posts snake case request body', () async {
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

  test('importExternalIngredient maps category-required response', () async {
    try {
      await repository.importExternalIngredient(
        sourceId: 'requires-category',
      );

      fail('Expected category-required exception.');
    } on ExternalIngredientCategoryRequiredException catch (error) {
      expect(lastRequest?.data, {
        'source_id': 'requires-category',
        'category_id': null,
      });

      expect(error.ingredient.sourceId, 'requires-category');
      expect(error.ingredient.name, 'Kimchi');
    }
  });

  test('importExternalIngredient retries with selected category id', () async {
    final ingredient = await repository.importExternalIngredient(
      sourceId: 'requires-category',
      categoryId: 4,
    );

    expect(lastRequest?.method, 'POST');
    expect(
      lastRequest?.path,
      '/api/ingredient-catalogue/add-external',
    );
    expect(lastRequest?.data, {
      'source_id': 'requires-category',
      'category_id': 4,
    });

    expect(ingredient.ingId, 25);
    expect(ingredient.name, 'Kimchi');
    expect(ingredient.category, 'Vegetables');
    expect(ingredient.requiresImport, isFalse);
  });
}
