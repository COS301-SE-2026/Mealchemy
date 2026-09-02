import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/connectivity_service.dart';

void main() {
  test('any HTTP response proves the backend is reachable', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response<void>(requestOptions: options, statusCode: 503),
        ),
      ),
    );

    expect(await DioBackendReachability(dio: dio).isReachable(), isTrue);
  });

  test('a Dio transport exception reports the backend unreachable', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          ),
        ),
      ),
    );

    expect(await DioBackendReachability(dio: dio).isReachable(), isFalse);
  });
}
