
import 'package:mealchemy/features/auth/models/user.dart';

class AuthResult {
  final bool success;
  final String? token;
  final User? user;
  final String? errorMessage;
   final bool onboardingRequired;

  const AuthResult({
    required this.success,
    this.token,
    this.user,
    this.errorMessage,
    this.onboardingRequired = false,
  });

  //Success result
  factory AuthResult.success({required String token, required User user, bool onboardingRequired = false}) {
    return AuthResult(success: true, token: token, user: user, onboardingRequired: onboardingRequired);
  }

  //Failure result
  factory AuthResult.failure(String message) {
    return AuthResult(success: false, errorMessage: message);
  }
}