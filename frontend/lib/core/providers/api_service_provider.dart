import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_interceptor.dart';

//10.0.2.2 is Android emulator's alias for the host machine's localhost.
//On macOS/iOS/desktop, use localhost directly, added a check to see machine
String get _baseUrl =>
    Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';


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
//Remove logging in production
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    requestHeader: true,
  ));

  dio.interceptors.add(interceptor);

  return dio;
});