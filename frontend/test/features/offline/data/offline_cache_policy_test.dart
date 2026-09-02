import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/offline/data/offline_cache_policy.dart';

void main() {
  final transportTypes = <DioExceptionType>[
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionError,
    DioExceptionType.badCertificate,
    DioExceptionType.unknown,
  ];

  for (final type in transportTypes) {
    test('$type is an offline transport failure', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/resource'),
        type: type,
      );

      expect(isOfflineTransportFailure(error), isTrue);
    });
  }

  test('HTTP responses, cancellation, and non-Dio errors are not offline', () {
    final options = RequestOptions(path: '/resource');
    final responseError = DioException.badResponse(
      statusCode: 503,
      requestOptions: options,
      response: Response<void>(requestOptions: options, statusCode: 503),
    );
    final cancelled = DioException(
      requestOptions: options,
      type: DioExceptionType.cancel,
    );

    expect(isOfflineTransportFailure(responseError), isFalse);
    expect(isOfflineTransportFailure(cancelled), isFalse);
    expect(isOfflineTransportFailure(StateError('not Dio')), isFalse);
  });
}
