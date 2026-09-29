import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/core/connectivity/offline_mutation_interceptor.dart';
import 'package:mealchemy/core/services/auth_interceptor.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_report_repository.dart';

void main() {
  late Dio dio;
  late ApiRecipeReportRepository repository;
  late List<RequestOptions> requests;
  late Object? responseData;
  DioException? failure;

  setUp(() {
    requests = [];
    failure = null;
    responseData = [
      {'value': 'SPAM', 'label': 'Spam or misleading content'},
    ];

    dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);

          final error = failure;
          if (error != null) {
            handler.reject(error);
            return;
          }

          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: responseData,
            ),
          );
        },
      ),
    );

    repository = ApiRecipeReportRepository(dio);
  });

  tearDown(() => dio.close(force: true));

  test('loads backend reason values and labels', () async {
    final reasons = await repository.getReasons();

    expect(requests.single.method, 'GET');
    expect(requests.single.path, '/flagreasons/all');
    expect(reasons.single.value, 'SPAM');
    expect(reasons.single.label, 'Spam or misleading content');
  });

  test('preserves an empty reason list', () async {
    responseData = [];

    expect(await repository.getReasons(), isEmpty);
  });

  test('rejects duplicate reason values', () async {
    responseData = [
      {'value': 'SPAM', 'label': 'Spam'},
      {'value': 'SPAM', 'label': 'Another label'},
    ];

    await expectLater(
      repository.getReasons(),
      throwsA(isA<FormatException>()),
    );
  });

  test('posts reason_value to the selected recipe', () async {
    responseData = {};

    await repository.reportRecipe(
      recipeId: 87,
      reasonValue: 'SPAM',
    );

    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/recipes/87/flag');
    expect(requests.single.data, {'reason_value': 'SPAM'});
  });

  test('uses authentication from the injected client', () async {
    dio.interceptors.insert(
      0,
      AuthInterceptor()..setToken('test-token'),
    );

    await repository.reportRecipe(recipeId: 87, reasonValue: 'SPAM');

    expect(
      requests.single.headers['Authorization'],
      'Bearer test-token',
    );
  });

  for (final status in [400, 401, 403, 404, 409, 500]) {
    test('preserves HTTP $status for the reporting flow', () async {
      final options = RequestOptions(path: '/recipes/87/flag');
      failure = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: status,
          data: {'message': 'Backend explanation'},
        ),
      );

      await expectLater(
        repository.reportRecipe(recipeId: 87, reasonValue: 'SPAM'),
        throwsA(same(failure)),
      );
    });
  }

  for (final network in [NetworkStatus.offline, NetworkStatus.checking]) {
    test('existing interceptor blocks reports while ${network.name}', () async {
      dio.interceptors.insert(
        0,
        OfflineMutationInterceptor(() => network),
      );

      await expectLater(
        repository.reportRecipe(recipeId: 87, reasonValue: 'SPAM'),
        throwsA(isA<DioException>()),
      );

      expect(requests, isEmpty);
    });
  }
}
