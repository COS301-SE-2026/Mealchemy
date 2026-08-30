import 'package:dio/dio.dart';

bool isOfflineTransportFailure(Object error) {
  if (error is! DioException || error.response != null) return false;

  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.connectionError ||
    DioExceptionType.badCertificate ||
    DioExceptionType.unknown =>
      true,
    DioExceptionType.badResponse || DioExceptionType.cancel => false,
  };
}
