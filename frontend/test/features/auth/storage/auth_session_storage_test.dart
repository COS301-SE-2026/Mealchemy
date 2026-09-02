import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/auth/models/user.dart';
import 'package:mealchemy/features/auth/storage/auth_session_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('writes and restores identity independently from the token', () async {
    final storage = SecureAuthSessionStorage();
    const user = User(
      userId: 7,
      email: 'chef@mealchemy.com',
      displayName: 'Chef',
      role: 'user',
    );

    await storage.writeIdentity(user);
    final restored = await storage.readIdentity();
    expect(restored?.userId, user.userId);
    expect(restored?.email, user.email);
    expect(restored?.displayName, user.displayName);
    expect(restored?.role, user.role);
    expect(await storage.readToken(), isNull);

    await storage.writeToken('token');
    expect(await storage.readToken(), 'token');
    expect((await storage.readIdentity())?.userId, user.userId);
  });

  test('clears identity and token independently', () async {
    final storage = SecureAuthSessionStorage();
    const user = User(
      userId: 7,
      email: 'chef@mealchemy.com',
      displayName: 'Chef',
      role: 'user',
    );
    await storage.writeIdentity(user);
    await storage.writeToken('token');

    await storage.clearToken();
    expect(await storage.readToken(), isNull);
    expect((await storage.readIdentity())?.userId, user.userId);

    await storage.clearIdentity();
    expect(await storage.readIdentity(), isNull);
  });

  test('malformed persisted identity degrades to no known user', () async {
    FlutterSecureStorage.setMockInitialValues({
      'auth.identity': 'not-json',
    });

    expect(await SecureAuthSessionStorage().readIdentity(), isNull);
  });
}
