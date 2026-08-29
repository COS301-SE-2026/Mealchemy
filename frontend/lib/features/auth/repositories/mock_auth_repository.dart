import 'dart:convert';

import 'auth_repository.dart';
import '../models/auth_result.dart';
import '../models/user.dart';

//Mock implemenation will always return success 
class MockAuthRepository implements AuthRepository {
  @override
  Future<AuthResult> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return AuthResult.success(
      token: _mockToken(1),
      user: User(
        userId: 1,
        email: email,
        displayName: 'Test User',
        role: 'user',
      ),
    );
  }

  @override
  Future<AuthResult> register(
    String email,
    String password,
    String displayName,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return AuthResult.success(
      token: _mockToken(99),
      user: User(
        userId: 99,
        email: email,
        displayName: displayName,
        role: 'user',
      ),
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
  
  String _mockToken(int userId) {
    final header = base64Url
        .encode(utf8.encode(jsonEncode({'alg': 'none', 'typ': 'JWT'})))
        .replaceAll('=', '');
    final payload = base64Url
        .encode(utf8.encode(jsonEncode({
          'sub': '$userId',
          'exp': 4102444800,
        })))
        .replaceAll('=', '');
    return '$header.$payload.mock';
  }
}