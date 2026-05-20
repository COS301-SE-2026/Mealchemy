import '../models/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> register(String email, String password, String displayName);
  Future<void> logout();
}