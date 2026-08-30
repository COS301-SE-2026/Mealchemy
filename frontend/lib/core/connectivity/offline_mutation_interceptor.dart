import 'package:dio/dio.dart';

import 'network_status_provider.dart';

class OfflineMutationException implements Exception {
  const OfflineMutationException();

  @override
  String toString() => 'Changes are unavailable while offline.';
}

class OfflineMutationInterceptor extends Interceptor {
  OfflineMutationInterceptor(this._readStatus);

  final NetworkStatus Function() _readStatus;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_isMutation(options) && _readStatus() != NetworkStatus.online) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: const OfflineMutationException(),
          message: 'Changes are unavailable while offline.',
        ),
      );
      return;
    }
    handler.next(options);
  }

  bool _isMutation(RequestOptions options) {
    final method = options.method.toUpperCase();
    if (method == 'GET' || method == 'HEAD' || method == 'OPTIONS') {
      return false;
    }

    return !options.path.startsWith('/auth/');
  }
}
