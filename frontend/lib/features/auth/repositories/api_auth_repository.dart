import 'package:dio/dio.dart';
import 'auth_repository.dart';
import '../models/auth_result.dart';
import '../models/user.dart';

class ApiAuthRepository implements AuthRepository {
  final Dio _dio;

  ApiAuthRepository(this._dio);
//login method calls
  @override
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return AuthResult.success(
        token: response.data['token'],
        user: User.fromJson(response.data['user']),
      );
    } catch (e) {
      return AuthResult.failure('Invalid email or password');
    }
  }
//register method calls for thge sign up page 
  @override
  Future<AuthResult> register(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'display_name': displayName,
      });
      return AuthResult.success(
        token: response.data['token'],
        user: User.fromJson(response.data['user']),
      );
    } catch (e) {
      return AuthResult.failure('Something went wrong. Please try again.');
    }
  }
//logout method calls
  @override
  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }
}