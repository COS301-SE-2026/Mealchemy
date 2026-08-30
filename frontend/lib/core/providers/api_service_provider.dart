import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connectivity/backend_config.dart';
import '../connectivity/network_status_provider.dart';
import '../connectivity/offline_mutation_interceptor.dart';
import '../services/auth_interceptor.dart';

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor();
});

final dioProvider = Provider<Dio>((ref) {
  final interceptor = ref.read(authInterceptorProvider);
  final networkStatus = ref.read(networkStatusProvider.notifier);

  final dio = Dio(
    BaseOptions(
      baseUrl: backendBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  //only log in debug. release builds don't log request bodies
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
    ));
  }

  dio.interceptors.add(
    OfflineMutationInterceptor(() => ref.read(networkStatusProvider)),
  );
  dio.interceptors.add(NetworkStatusInterceptor(networkStatus));
  dio.interceptors.add(interceptor);

  return dio;
});