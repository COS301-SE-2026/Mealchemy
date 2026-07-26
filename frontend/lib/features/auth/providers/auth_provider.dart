import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealchemy/core/constants/app_config.dart';
import '../models/user.dart';
import '../repositories/api_auth_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/mock_auth_repository.dart';
import '../../../core/providers/api_service_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockAuthRepository();
  }
  return ApiAuthRepository(ref.read(dioProvider));
});

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? errorMessage;
  final String? token;
  final User? user;
  final bool onboardingRequired;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.errorMessage,
    this.token,
    this.user,
    this.onboardingRequired = false,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? errorMessage,
    String? token,
    User? user,
    bool? onboardingRequired,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      token: token ?? this.token,
      user: user ?? this.user,
      onboardingRequired: onboardingRequired ?? this.onboardingRequired,
    );
  }

  int? get userId {
    if (user != null) return user!.userId;
    if (token == null) return null;
    final parts = token!.split('.');
    if (parts.length != 3) return null;

    try {
      final decoded =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final map = jsonDecode(decoded);
      return int.tryParse('${map['sub']}');
    } catch (_) {
      return null;
    }
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(const AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.login(email, password);

    if (result.success) {
      _ref.read(authInterceptorProvider).setToken(result.token);

      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        token: result.token,
        user: result.user,
        onboardingRequired: result.onboardingRequired,
      );
      return true;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.errorMessage,
    );
    return false;
  }

  Future<bool> register(
    String email,
    String password,
    String displayName,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.register(email, password, displayName);

    if (result.success) {
      _ref.read(authInterceptorProvider).setToken(result.token);

      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        token: result.token,
        user: result.user,
        onboardingRequired: result.onboardingRequired,
      );
      return true;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.errorMessage,
    );
    return false;
  }

  Future<void> logout() async {
    await _repository.logout();

    _ref.read(authInterceptorProvider).setToken(null);
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider), ref);
});