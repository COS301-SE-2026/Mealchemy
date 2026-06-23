import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/api_auth_repository.dart';
import '../repositories/auth_repository.dart';
import '../../../core/providers/api_service_provider.dart';
import 'dart:convert';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(ref.read(dioProvider));
});

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? errorMessage;
  final String? token;
  final bool onboardingRequired;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.errorMessage,
    this.token,
    this.onboardingRequired = false,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? errorMessage,
    String? token,
    bool? onboardingRequired,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      token: token ?? this.token,
      onboardingRequired: onboardingRequired ?? this.onboardingRequired,
    );
  }

  int? get userId {
    if (token == null) return null;
    final parts = token!.split('.');
    final payload = parts[1];
    final decoded = utf8.decode(base64Url.decode(base64Url.normalize(payload)));
    final map = jsonDecode(decoded);
    return int.tryParse(map['sub']);
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
