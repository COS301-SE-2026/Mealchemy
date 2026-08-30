import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/services/auth_interceptor.dart';

void main() {
  test('adds the current token and stops adding it after token removal', () {
    final interceptor = AuthInterceptor();
    interceptor.setToken('secret');
    final authenticated = RequestOptions(path: '/private');

    interceptor.onRequest(authenticated, RequestInterceptorHandler());

    expect(authenticated.headers['Authorization'], 'Bearer secret');

    interceptor.setToken(null);
    final anonymous = RequestOptions(path: '/public');
    interceptor.onRequest(anonymous, RequestInterceptorHandler());

    expect(anonymous.headers, isNot(contains('Authorization')));
  });

  test('authenticated 401 clears only the credential and notifies auth',
      () async {
    final interceptor = AuthInterceptor();
    var unauthorizedCalls = 0;
    interceptor
      ..setToken('expired')
      ..setUnauthorizedHandler(() => unauthorizedCalls++);
    final options = RequestOptions(
      path: '/private',
      headers: {'Authorization': 'Bearer expired'},
    );

    final handler = ErrorInterceptorHandler();
    final forwarded = expectLater(
      handler.future,
      throwsA(anything),
    );
    interceptor.onError(
      DioException.badResponse(
        statusCode: 401,
        requestOptions: options,
        response: Response<void>(requestOptions: options, statusCode: 401),
      ),
      handler,
    );
    await forwarded;

    final afterUnauthorized = RequestOptions(path: '/private');
    interceptor.onRequest(afterUnauthorized, RequestInterceptorHandler());
    expect(unauthorizedCalls, 1);
    expect(afterUnauthorized.headers, isNot(contains('Authorization')));
  });

  test('anonymous 401 and authenticated non-401 responses do not notify',
      () async {
    final interceptor = AuthInterceptor();
    var unauthorizedCalls = 0;
    interceptor.setUnauthorizedHandler(() => unauthorizedCalls++);

    for (final entry in <(int, Map<String, dynamic>)>[
      (401, const {}),
      (403, const {'Authorization': 'Bearer valid'}),
    ]) {
      final options = RequestOptions(path: '/resource', headers: entry.$2);
      final handler = ErrorInterceptorHandler();
      final forwarded = expectLater(
        handler.future,
        throwsA(anything),
      );
      interceptor.onError(
        DioException.badResponse(
          statusCode: entry.$1,
          requestOptions: options,
          response: Response<void>(
            requestOptions: options,
            statusCode: entry.$1,
          ),
        ),
        handler,
      );
      await forwarded;
    }

    expect(unauthorizedCalls, 0);
  });
}
