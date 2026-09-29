import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mealchemy/features/auth/repositories/api_auth_repository.dart';

void main() {
  Dio failingDio(int status, {String? retryAfter}) {
    final dio = Dio();

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.badResponse,
              response: Response<dynamic>(
                requestOptions: options,
                statusCode: status,
                headers: Headers.fromMap({
                  if (retryAfter != null) 'Retry-After': [retryAfter],
                }),
                data: {
                  'message': 'Server message without a countdown.',
                },
              ),
            ),
          );
        },
      ),
    );

    addTearDown(() => dio.close(force: true));
    return dio;
  }

  test('429 reads remaining seconds from the response header', () async {
    final repository = ApiAuthRepository(
      failingDio(429, retryAfter: '127'),
    );

    final result = await repository.login('test@example.com', 'password');

    expect(result.success, isFalse);
    expect(result.retryAfterSeconds, 127);
  });

  for (final header in <String?>[
    null,
    '',
    'invalid',
    '-1',
    '1.5',
    '999999999999999999999999',
  ]) {
    test('429 falls back safely for header $header', () async {
      final repository = ApiAuthRepository(
        failingDio(429, retryAfter: header),
      );

      final result = await repository.login('test@example.com', 'password');

      expect(result.retryAfterSeconds, 300);
    });
  }

  test('zero remaining seconds is accepted', () async {
    final repository = ApiAuthRepository(
      failingDio(429, retryAfter: '0'),
    );

    final result = await repository.login('test@example.com', 'password');

    expect(result.retryAfterSeconds, 0);
  });

  test('401 remains an ordinary credential error', () async {
    final repository = ApiAuthRepository(failingDio(401));

    final result = await repository.login('test@example.com', 'password');

    expect(result.retryAfterSeconds, isNull);
    expect(result.errorMessage, 'Invalid email or password');
  });

  test('registration 429 does not create a password-login lockout', () async {
    final repository = ApiAuthRepository(
      failingDio(429, retryAfter: '300'),
    );

    final result = await repository.register(
      'test@example.com',
      'password',
      'Test',
    );

    expect(result.success, isFalse);
    expect(result.retryAfterSeconds, isNull);
  });
}
