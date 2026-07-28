import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_interceptor.dart';


const String _productionBaseUrl = String.fromEnvironment('BACKEND_URL', defaultValue: '');

String get _baseUrl {
  if (_productionBaseUrl.isNotEmpty) return _productionBaseUrl;
  // 10.0.2.2 is the Android emulator's alias for the host machine's localhost.
  //if no real backend adress, use local dev
  return Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
}

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor();
});

final dioProvider = Provider<Dio>((ref) {
  final interceptor = ref.read(authInterceptorProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
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

  dio.interceptors.add(interceptor);

  return dio;
});