import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/auth/models/user.dart';

void main() {
  group('User constructor', () {
    test('creates an  instance with all provided fields', () {
      const user = User(
        userId: 1,
        email: 'jane.doe@example.com',
        displayName: 'Jane Doe',
        role: 'admin',
      );
      
      expect(user.userId, 1);
      expect(user.email, 'jane.doe@example.com');
      expect(user.displayName, 'Jane Doe');
      expect(user.role, 'admin');
    });
  });

  group('User.fromJson', () {

    test('creates a valid instance from JSON', () {
      final json = {
        'userId': 7,
        'email': 'alice@example.com',
        'displayName': 'Alice',
        'role': 'admin',
      };

      final user = User.fromJson(json);
      expect(user.userId, 7);
      expect(user.email, 'alice@example.com');
      expect(user.displayName, 'Alice');
      expect(user.role, 'admin');
    });
    test('throws when a field has the wrong type', () {
      final json = {
        'userId': '7',
        'email': 'alice@example.com',
        'displayName': 'Alice',
        'role': 'admin',
      };
      expect(() => User.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('throws when a required field is missing', () {
      final json = {
        'userId': 7,
        'email': 'alice@example.com',
        'displayName': 'Alice',
      };
      expect(() => User.fromJson(json), throwsA(isA<TypeError>()));
    });
  });
}
