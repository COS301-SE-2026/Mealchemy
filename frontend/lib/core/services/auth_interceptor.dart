import 'package:dio/dio.dart';


//Token is set externally by auth_provider after login
class AuthInterceptor extends Interceptor {
  String? _token;

  //Called by auth provider after successful login
  void setToken(String? token) {
    _token = token;
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
    //Clear token if backend says it is invalid
    if (err.response?.statusCode == 401) {
      _token = null;
    }
    handler.next(err);
  }
}