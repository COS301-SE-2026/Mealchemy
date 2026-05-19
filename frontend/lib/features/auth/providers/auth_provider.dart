// Holds everything related to the logged-in user (JWT + auth status).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../repositories/mock_auth_repository.dart';
import '../repositories/api_auth_repository.dart';
import '../repositories/auth_repository.dart';
import '../models/auth_result.dart';
import '../../../core/constants/app_config.dart';

//Switch between mock and real API implementations based on config 
//Will be removed before deployement
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockAuthRepository();
  }
  return ApiAuthRepository(Dio());
});

//Auth state this holds the current auth states 
class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? errorMessage;
  final String? token;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.errorMessage,
    this.token,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? errorMessage,
    String? token,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      token: token ?? this.token,
    );
  }
}

//Auth Notifier this holds the logic for handling login/signup/logout
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.login(email, password);

    if (result.success) {
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        token: result.token,
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
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        token: result.token,
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
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});