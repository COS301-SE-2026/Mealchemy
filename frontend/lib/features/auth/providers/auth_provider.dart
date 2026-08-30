import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mealchemy/core/constants/app_config.dart';
import '../models/auth_result.dart';
import '../models/user.dart';
import '../repositories/api_auth_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/mock_auth_repository.dart';
import '../storage/auth_session_storage.dart';
import '../../../core/providers/api_service_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConfig.mockAuth) {
    return MockAuthRepository();
  }
  return ApiAuthRepository(ref.read(dioProvider));
});

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final bool isRestoring;
  final bool hasValidCredential;
  final String? errorMessage;
  final String? token;
  final User? user;
  final bool onboardingRequired;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.isRestoring = false,
    this.hasValidCredential = false,
    this.errorMessage,
    this.token,
    this.user,
    this.onboardingRequired = false,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    bool? isRestoring,
    bool? hasValidCredential,
    String? errorMessage,
    String? token,
    User? user,
    bool? onboardingRequired,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      isRestoring: isRestoring ?? this.isRestoring,
      hasValidCredential: hasValidCredential ?? this.hasValidCredential,
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

  bool get requiresReauthentication =>
      isLoggedIn && !isRestoring && !hasValidCredential;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(const AuthState());

  Future<void>? _restoreFuture;

  AuthSessionStorage get _storage => _ref.read(authSessionStorageProvider);

  Future<void> restore() {
    return _restoreFuture ??= _restore();
  }

  Future<void> _restore() async {
    state = state.copyWith(isRestoring: true, errorMessage: null);

    User? identity;
    String? token;

    try {
      identity = await _storage.readIdentity();
    } catch (_) {
      identity = null;
    }

    try {
      token = await _storage.readToken();
    } catch (_) {
      token = null;
    }

    if (identity == null) {
      _ref.read(authInterceptorProvider).setToken(null);
      state = const AuthState();
      return;
    }

    final credentialIsValid =
        token != null && _tokenMatchesIdentity(token, identity.userId);

    if (credentialIsValid) {
      _ref.read(authInterceptorProvider).setToken(token);
    } else {
      _ref.read(authInterceptorProvider).setToken(null);
      unawaited(_clearStoredTokenSafely());
    }

    state = AuthState(
      isLoggedIn: true,
      isRestoring: false,
      hasValidCredential: credentialIsValid,
      token: credentialIsValid ? token : null,
      user: identity,
    );
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.login(email, password);

    if (result.success) {
      return _acceptAuthentication(result);
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
      return _acceptAuthentication(result);
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.errorMessage,
    );
    return false;
  }

  Future<void> logout() async {
    final remoteLogout = state.hasValidCredential
        ? _repository.logout().catchError((_) {})
        : Future<void>.value();
    _ref.read(authInterceptorProvider).setToken(null);
    state = const AuthState();

    await Future.wait([
      _clearStoredIdentitySafely(),
      _clearStoredTokenSafely(),
    ]);

    //Local logout is authoritative
    //missing network musn't keep the user signed in on the device.
    unawaited(remoteLogout);
  }

  void invalidateCredential() {
    if (!state.hasValidCredential && state.token == null) return;

    _ref.read(authInterceptorProvider).setToken(null);
    state = AuthState(
      isLoggedIn: state.userId != null,
      isLoading: false,
      isRestoring: false,
      hasValidCredential: false,
      user: state.user,
      onboardingRequired: state.onboardingRequired,
    );
    unawaited(_clearStoredTokenSafely());
  }

  Future<bool> _acceptAuthentication(AuthResult result) async {
    final user = result.user;
    final token = result.token;

    if (user == null ||
        token == null ||
        !_tokenMatchesIdentity(token, user.userId)) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'The authentication response was invalid.',
      );
      return false;
    }

    try {
      await _storage.writeToken(token);
      await _storage.writeIdentity(user);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to store the signed-in session securely.',
      );
      return false;
    }

    _ref.read(authInterceptorProvider).setToken(token);
    state = AuthState(
      isLoggedIn: true,
      isLoading: false,
      isRestoring: false,
      hasValidCredential: true,
      token: token,
      user: user,
      onboardingRequired: result.onboardingRequired,
    );

    return true;
  }

  bool _tokenMatchesIdentity(String token, int userId) {
    try {
      if (JwtDecoder.isExpired(token)) return false;
      final subject = JwtDecoder.decode(token)['sub'];
      return int.tryParse('$subject') == userId;
    } catch (_) {
      return false;
    }
  }

  Future<void> _clearStoredIdentitySafely() async {
    try {
      await _storage.clearIdentity();
    } catch (_) {
      // The inmemory logout still succeeds when device storage is unhealthy.
    }
  }

  Future<void> _clearStoredTokenSafely() async {
    try {
      await _storage.clearToken();
    } catch (_) {
      // An unreadable credential is already treated as absent.
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier(ref.watch(authRepositoryProvider), ref);
  final interceptor = ref.read(authInterceptorProvider);

  interceptor.setUnauthorizedHandler(notifier.invalidateCredential);
  ref.onDispose(() => interceptor.setUnauthorizedHandler(null));
  unawaited(notifier.restore());

  return notifier;
});

// Cache repositories watch this selected value, not the full auth state
// Token renewal for the same user therefore cannot emit a namespace change.
final activeIdentityProvider = Provider<int?>((ref) {
  return ref.watch(authProvider.select((state) => state.userId));
});
