import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/discovery/repositories/api_discovery_repository.dart';

void main() {
  late ApiDiscoveryRepository repository;

  setUp(() {
    final dio = Dio();

    //keep the repo test fast and offline
    //without calling the real backend
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.method == 'GET' &&
              options.path == '/recipes/community') {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: [
                  {
                    'recipeId': 1,
                    'title': 'Saffron Risotto',
                  },
                  {
                    'recipeId': 2,
                    'title': 'Butter Chicken',
                  },
                ],
              ),
            );
            return;
          }
          if (options.method == 'GET' &&
              options.path == '/flavourprofileoptions/all') {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: [
                  {'value': 'Italian'},
                  {'value': 'Indian'},
                ],
              ),
            );
            return;
          }

          handler.reject(
            DioException(
              requestOptions: options,
              error: 'Unhandled request in test: ${options.path}',
            ),
          );
        },
      ),
    );

    repository = ApiDiscoveryRepository(dio);
  });

  test('getPublishedRecipes maps backend recipes JSON into Recipe list',
      () async {
    final recipes = await repository.getPublishedRecipes();

    expect(recipes, hasLength(2));
    expect(recipes.first.recipeId, 1);
    expect(recipes.first.title, 'Saffron Risotto');
    expect(recipes.last.recipeId, 2);
    expect(recipes.last.title, 'Butter Chicken');
  });

  test('getCuisineTypes maps flavour profile options into cuisine strings',
      () async {
    final cuisines = await repository.getCuisineTypes();

    expect(cuisines, ['Italian', 'Indian']);
  });
}