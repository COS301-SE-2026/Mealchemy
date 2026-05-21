import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_interceptor.dart';


final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor();
});


final dioProvider = Provider<Dio>((ref) {
  final interceptor = ref.read(authInterceptorProvider);

  final dio = Dio(
    BaseOptions(

      baseUrl: 'http://10.0.2.2:8080/api/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
//TODO: Remove logging in production
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    requestHeader: true,
  ));

  dio.interceptors.add(interceptor);

  return dio;
});