import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('returns null for valid email', () {
        expect(Validators.email('test@mealchemy.com'), isNull);
      });

      test('returns error for empty email', () {
        expect(Validators.email(''), isNotNull);
      });

      test('returns error for null email', () {
        expect(Validators.email(null), isNotNull);
      });

      test('returns error for email without @', () {
        expect(Validators.email('testmealchemy.com'), isNotNull);
      });

      test('returns error for email without domain', () {
        expect(Validators.email('test@'), isNotNull);
      });
    });

    group('password', () {
      test('returns null for valid password', () {
        expect(Validators.password('password123'), isNull);
      });

      test('returns error for empty password', () {
        expect(Validators.password(''), isNotNull);
      });

      test('returns error for null password', () {
        expect(Validators.password(null), isNotNull);
      });

      test('returns error for password less than 8 characters', () {
        expect(Validators.password('short'), isNotNull);
      });

      test('returns null for password exactly 8 characters', () {
        expect(Validators.password('12345678'), isNull);
      });
    });

    group('confirmPassword', () {
      test('returns null when passwords match', () {
        expect(
            Validators.confirmPassword('password123', 'password123'), isNull);
      });

      test('returns error when passwords do not match', () {
        expect(
            Validators.confirmPassword('password123', 'different'), isNotNull);
      });

      test('returns error for empty confirm password', () {
        expect(Validators.confirmPassword('', 'password123'), isNotNull);
      });

      test('returns error for null confirm password', () {
        expect(Validators.confirmPassword(null, 'password123'), isNotNull);
      });
    });

    group('textField', () {
      test('returns null for valid display name', () {
        expect(Validators.textField('Mutombo'), isNull);
      });

      test('returns error for empty display name', () {
        expect(Validators.textField(''), isNotNull);
      });

      test('returns error for null display name', () {
        expect(Validators.textField(null), isNotNull);
      });

      test('returns error for display name less than 2 characters', () {
        expect(Validators.textField('M'), isNotNull);
      });

      test('returns null for display name exactly 2 characters', () {
        expect(Validators.textField('Mo'), isNull);
      });
    });
  });
}
