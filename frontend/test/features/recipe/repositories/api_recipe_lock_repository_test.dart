import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/core/connectivity/offline_mutation_interceptor.dart';
import 'package:mealchemy/core/services/auth_interceptor.dart';
import 'package:mealchemy/features/recipe/repositories/api_recipe_lock_repository.dart';

void main() {
  late Dio dio;
  late ApiRecipeLockRepository repository;
  late List<RequestOptions> requests;
  late int status;
  late Object? data;
  DioException? failure;

  setUp(() {
    requests = [];
    status = 200;
    failure = null;
    data = {
      'recipeId': 8,
      'lockedByUserId': 2,
      'lockedByEmail': 'editor@example.com',
      'acquiredAt': '2026-09-24T10:00:00Z',
      'expiresAt': '2026-09-24T10:01:30Z',
    };

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
              statusCode: status,
              data: data,
            ),
          );
        },
      ),
    );

    repository = ApiRecipeLockRepository(dio);
  });

  tearDown(() => dio.close(force: true));

  test('GET parses an active lock', () async {
    final lock = await repository.getLock(8);

    expect(lock!.lockedByUserId, 2);
    expect(requests.single.method, 'GET');
    expect(requests.single.path, '/recipes/8/lock');
  });

  test('GET 204 returns null without parsing a body', () async {
    status = 204;
    data = '';

    expect(await repository.getLock(8), isNull);
  });

  test('POST acquires or refreshes without a request body', () async {
    final lock = await repository.acquireLock(8);

    expect(lock.recipeId, 8);
    expect(requests.single.method, 'POST');
    expect(requests.single.path, '/recipes/8/lock');
    expect(requests.single.data, isNull);
  });

  test('DELETE accepts an empty 204 response', () async {
    status = 204;
    data = '';

    await repository.releaseLock(8);

    expect(requests.single.method, 'DELETE');
    expect(requests.single.path, '/recipes/8/lock');
    expect(requests.single.data, isNull);
  });

  test('uses the injected authentication interceptor', () async {
    dio.interceptors.insert(
      0,
      AuthInterceptor()..setToken('test-token'),
    );

    await repository.acquireLock(8);

    expect(
      requests.single.headers['Authorization'],
      'Bearer test-token',
    );
  });

  test('rejects a response for a different recipe', () async {
    data = {
      ...(data as Map<String, dynamic>),
      'recipeId': 99,
    };

    await expectLater(
      repository.acquireLock(8),
      throwsA(isA<FormatException>()),
    );
  });

  test('GET 200 with an empty body is not treated as an unlocked recipe',
      () async {
    data = null;

    await expectLater(
      repository.getLock(8),
      throwsA(isA<FormatException>()),
    );
  });

  test('POST 204 is not treated as a successful acquisition', () async {
    status = 204;
    data = null;

    await expectLater(
      repository.acquireLock(8),
      throwsA(isA<FormatException>()),
    );
  });

  test('invalid recipe IDs do not send requests', () async {
    await expectLater(
      repository.getLock(0),
      throwsArgumentError,
    );
    await expectLater(
      repository.acquireLock(-1),
      throwsArgumentError,
    );
    await expectLater(
      repository.releaseLock(0),
      throwsArgumentError,
    );

    expect(requests, isEmpty);
  });

  for (final code in [401, 403, 404, 409, 500]) {
    test('preserves HTTP $code for all lock operations', () async {
      final options = RequestOptions(path: '/recipes/8/lock');
      failure = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: code,
          data: {'message': 'Backend explanation'},
        ),
      );

      await expectLater(
        repository.getLock(8),
        throwsA(same(failure)),
      );
      await expectLater(
        repository.acquireLock(8),
        throwsA(same(failure)),
      );
      await expectLater(
        repository.releaseLock(8),
        throwsA(same(failure)),
      );
    });
  }

  test('preserves transport failures', () async {
    failure = DioException(
      requestOptions: RequestOptions(path: '/recipes/8/lock'),
      type: DioExceptionType.connectionTimeout,
    );

    await expectLater(
      repository.acquireLock(8),
      throwsA(same(failure)),
    );
  });

  for (final network in [
    NetworkStatus.offline,
    NetworkStatus.checking,
  ]) {
    test('blocks lock mutations while ${network.name}', () async {
      dio.interceptors.insert(
        0,
        OfflineMutationInterceptor(() => network),
      );

      await expectLater(
        repository.acquireLock(8),
        throwsA(isA<DioException>()),
      );
      await expectLater(
        repository.releaseLock(8),
        throwsA(isA<DioException>()),
      );

      expect(requests, isEmpty);
    });
  }
}
