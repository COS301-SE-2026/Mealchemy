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
        user: User(
          userId: response.data['user_id'],
          email: email,
          displayName: '',
          role: 'user',
        ),
        onboardingRequired: response.data['onboarding_required'] ?? false,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return AuthResult.failure('Invalid email or password');
      }
      return AuthResult.failure(_messageFrom(e));
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
        'displayName': displayName,
      });
      return AuthResult.success(
        token: response.data['token'],
        user: User(
          userId: response.data['user_id'],
          email: email,
          displayName: displayName,
          role: 'user',
        ),
        onboardingRequired: response.data['onboarding_required'] ?? false,
      );
    } on DioException catch (e) {
      return AuthResult.failure(_messageFrom(e));
    }
  }

  @override
  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  String _messageFrom(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return 'Something went wrong. Please try again.';
  }
}