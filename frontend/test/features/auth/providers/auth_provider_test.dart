import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/providers/api_service_provider.dart';
import 'package:mealchemy/core/services/auth_interceptor.dart';
import 'package:mealchemy/features/auth/models/auth_result.dart';
import 'package:mealchemy/features/auth/models/user.dart';
import 'package:mealchemy/features/auth/providers/auth_provider.dart';
import 'package:mealchemy/features/auth/repositories/auth_repository.dart';
import 'package:mealchemy/features/auth/storage/auth_session_storage.dart';

void main() {
  group('AuthNotifier offline identity', () {
    test('keeps identity when the persisted token has expired', () async {
      final storage = _FakeAuthSessionStorage(
        identity: _user(7),
        token: _jwt(7, expiresAt: DateTime(2020)),
      );
      final container = _container(storage: storage);
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).restore();

      final state = container.read(authProvider);
      expect(state.userId, 7);
      expect(state.isLoggedIn, isTrue);
      expect(state.hasValidCredential, isFalse);
      expect(state.requiresReauthentication, isTrue);
      expect(state.token, isNull);
    });

    test('same-user reauthentication resumes the existing identity', () async {
      final storage = _FakeAuthSessionStorage(
        identity: _user(7),
        token: _jwt(7, expiresAt: DateTime(2020)),
      );
      final repository = _FakeAuthRepository(
        loginResult: AuthResult.success(
          token: _jwt(7),
          user: _user(7),
        ),
      );
      final container = _container(storage: storage, repository: repository);
      addTearDown(container.dispose);
      final notifier = container.read(authProvider.notifier);
      await notifier.restore();

      final success = await notifier.login('user7@example.com', 'password');

      expect(success, isTrue);
      expect(container.read(authProvider).userId, 7);
      expect(container.read(authProvider).hasValidCredential, isTrue);
      expect(storage.clearIdentityCalls, 0);
    });

    test('switches identity only when authenticated user id differs', () async {
      final storage = _FakeAuthSessionStorage(
        identity: _user(7),
        token: _jwt(7),
      );
      final repository = _FakeAuthRepository(
        loginResult: AuthResult.success(
          token: _jwt(8),
          user: _user(8),
        ),
      );
      final container = _container(storage: storage, repository: repository);
      addTearDown(container.dispose);
      final notifier = container.read(authProvider.notifier);
      await notifier.restore();

      await notifier.login('user8@example.com', 'password');

      expect(container.read(authProvider).userId, 8);
      expect(storage.identity?.userId, 8);
    });

    test('unreadable secure storage degrades to no known user', () async {
      final storage = _FakeAuthSessionStorage(throwOnRead: true);
      final container = _container(storage: storage);
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).restore();

      final state = container.read(authProvider);
      expect(state.isRestoring, isFalse);
      expect(state.isLoggedIn, isFalse);
      expect(state.userId, isNull);
    });

    test('credential invalidation preserves persisted identity', () async {
      final storage = _FakeAuthSessionStorage(
        identity: _user(7),
        token: _jwt(7),
      );
      final container = _container(storage: storage);
      addTearDown(container.dispose);
      final notifier = container.read(authProvider.notifier);
      await notifier.restore();

      notifier.invalidateCredential();

      final state = container.read(authProvider);
      expect(state.userId, 7);
      expect(state.isLoggedIn, isTrue);
      expect(state.hasValidCredential, isFalse);
      expect(storage.clearIdentityCalls, 0);
    });

    test('logout clears local state even when remote logout fails', () async {
      final storage = _FakeAuthSessionStorage(
        identity: _user(7),
        token: _jwt(7),
      );
      final repository = _FakeAuthRepository(failLogout: true);
      final container = _container(storage: storage, repository: repository);
      addTearDown(container.dispose);
      final notifier = container.read(authProvider.notifier);
      await notifier.restore();

      await notifier.logout();

      expect(container.read(authProvider).isLoggedIn, isFalse);
      expect(storage.identity, isNull);
      expect(storage.token, isNull);
    });
  });
}

ProviderContainer _container({
  required _FakeAuthSessionStorage storage,
  _FakeAuthRepository? repository,
}) {
  return ProviderContainer(
    overrides: [
      authSessionStorageProvider.overrideWithValue(storage),
      authRepositoryProvider.overrideWithValue(
        repository ?? _FakeAuthRepository(),
      ),
      authInterceptorProvider.overrideWithValue(AuthInterceptor()),
    ],
  );
}

User _user(int id) => User(
      userId: id,
      email: 'user$id@example.com',
      displayName: 'User $id',
      role: 'user',
    );

String _jwt(int userId, {DateTime? expiresAt}) {
  final header = base64Url
      .encode(utf8.encode(jsonEncode({'alg': 'none', 'typ': 'JWT'})))
      .replaceAll('=', '');
  final payload = base64Url
      .encode(utf8.encode(jsonEncode({
        'sub': '$userId',
        'exp': (expiresAt ?? DateTime(2100)).millisecondsSinceEpoch ~/ 1000,
      })))
      .replaceAll('=', '');
  return '$header.$payload.test';
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.loginResult, this.failLogout = false});

  final AuthResult? loginResult;
  final bool failLogout;

  @override
  Future<AuthResult> login(String email, String password) async {
    return loginResult ?? AuthResult.failure('Not configured');
  }

  @override
  Future<AuthResult> register(
    String email,
    String password,
    String displayName,
  ) async {
    return loginResult ?? AuthResult.failure('Not configured');
  }

  @override
  Future<void> logout() async {
    if (failLogout) throw Exception('offline');
  }
}

class _FakeAuthSessionStorage implements AuthSessionStorage {
  _FakeAuthSessionStorage({
    this.identity,
    this.token,
    this.throwOnRead = false,
  });

  User? identity;
  String? token;
  final bool throwOnRead;
  int clearIdentityCalls = 0;

  @override
  Future<void> clearIdentity() async {
    clearIdentityCalls += 1;
    identity = null;
  }

  @override
  Future<void> clearToken() async {
    token = null;
  }

  @override
  Future<User?> readIdentity() async {
    if (throwOnRead) throw Exception('unreadable identity');
    return identity;
  }

  @override
  Future<String?> readToken() async {
    if (throwOnRead) throw Exception('unreadable token');
    return token;
  }

  @override
  Future<void> writeIdentity(User user) async {
    identity = user;
  }

  @override
  Future<void> writeToken(String value) async {
    token = value;
  }
}