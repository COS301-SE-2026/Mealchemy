import 'package:dio/dio.dart';

//Token is set externally by auth_provider after login
class AuthInterceptor extends Interceptor {
  String? _token;
  void Function()? _onUnauthorized;

  //Called by auth provider after successful login
  void setToken(String? token) {
    _token = token;
  }

  void setUnauthorizedHandler(void Function()? handler) {
    _onUnauthorized = handler;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    //Attach token if available
    if (_token != null) {
      options.headers['Authorization'] = 'Bearer $_token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // A 401 for an authenticated request invalidates only the API credential.
    // Persisted identity and offline data remain available.
    if (err.response?.statusCode == 401 &&
        err.requestOptions.headers.containsKey('Authorization')) {
      _token = null;
      _onUnauthorized?.call();
    }
    handler.next(err);
  }
}