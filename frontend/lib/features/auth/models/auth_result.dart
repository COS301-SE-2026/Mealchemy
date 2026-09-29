import 'package:mealchemy/features/auth/models/user.dart';

class AuthResult {
  final bool success;
  final String? token;
  final User? user;
  final String? errorMessage;
  final bool onboardingRequired;

  //present only when password login returns HTTP 429
  final int? retryAfterSeconds;

  const AuthResult({
    required this.success,
    this.token,
    this.user,
    this.errorMessage,
    this.onboardingRequired = false,
    this.retryAfterSeconds,
  });

  factory AuthResult.success({
    required String token,
    required User user,
    bool onboardingRequired = false,
  }) {
    return AuthResult(
      success: true,
      token: token,
      user: user,
      onboardingRequired: onboardingRequired,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult(
      success: false,
      errorMessage: message,
    );
  }

  factory AuthResult.locked(int retryAfterSeconds) {
    return AuthResult(
      success: false,
      errorMessage: 'Too many failed login attempts. Please try again later.',
      retryAfterSeconds: retryAfterSeconds,
    );
  }
}
