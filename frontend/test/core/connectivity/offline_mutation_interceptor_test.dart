import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/core/connectivity/offline_mutation_interceptor.dart';

void main() {
  test('offline mutations are rejected before reaching the HTTP adapter',
      () async {
    final adapter = _RecordingAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    dio.interceptors.add(
      OfflineMutationInterceptor(() => NetworkStatus.offline),
    );

    await expectLater(
      dio.post<void>('/recipes/create'),
      throwsA(
        isA<DioException>().having(
          (error) => error.error,
          'cause',
          isA<OfflineMutationException>(),
        ),
      ),
    );
    expect(adapter.requestCount, 0);
  });

  test('offline reads and authentication requests remain available', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    dio.interceptors.add(
      OfflineMutationInterceptor(() => NetworkStatus.offline),
    );

    await dio.get<void>('/recipes/all');
    await dio.post<void>('/auth/login');

    expect(adapter.requestCount, 2);
  });

  test('online mutations reach the HTTP adapter', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    dio.interceptors.add(
      OfflineMutationInterceptor(() => NetworkStatus.online),
    );

    await dio.delete<void>('/recipes/delete/42');

    expect(adapter.requestCount, 1);
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}
