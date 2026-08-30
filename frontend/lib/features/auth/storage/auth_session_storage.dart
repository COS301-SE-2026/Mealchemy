import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';

abstract class AuthSessionStorage {
  Future<User?> readIdentity();

  Future<String?> readToken();

  Future<void> writeIdentity(User user);

  Future<void> writeToken(String token);

  Future<void> clearIdentity();

  Future<void> clearToken();
}

class SecureAuthSessionStorage implements AuthSessionStorage {
  SecureAuthSessionStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
                synchronizable: false,
              ),
            );

  static const _identityKey = 'auth.identity';
  static const _tokenKey = 'auth.api_token';

  final FlutterSecureStorage _storage;

  @override
  Future<User?> readIdentity() async {
    try {
      final value = await _storage.read(key: _identityKey);
      if (value == null) return null;

      final json = jsonDecode(value) as Map<String, dynamic>;
      return User(
        userId: json['userId'] as int,
        email: json['email']?.toString() ?? '',
        displayName: json['displayName']?.toString() ?? '',
        role: json['role']?.toString() ?? 'user',
      );
    } catch (_) {
      // Unreadable device storage never makes the app crash on launch
      return null;
    }
  }

  @override
  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> writeIdentity(User user) {
    return _storage.write(
      key: _identityKey,
      value: jsonEncode({
        'userId': user.userId,
        'email': user.email,
        'displayName': user.displayName,
        'role': user.role,
      }),
    );
  }

  @override
  Future<void> writeToken(String token) {
    return _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<void> clearIdentity() {
    return _storage.delete(key: _identityKey);
  }

  @override
  Future<void> clearToken() {
    return _storage.delete(key: _tokenKey);
  }
}

final authSessionStorageProvider = Provider<AuthSessionStorage>((ref) {
  return SecureAuthSessionStorage();
});
