import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/recipe_edit_lock.dart';

Map<String, dynamic> _json() => {
      'recipeId': 8,
      'lockedByUserId': 2,
      'lockedByEmail': 'editor@example.com',
      'acquiredAt': '2026-09-24T10:00:00Z',
      'expiresAt': '2026-09-24T10:01:30Z',
    };

void main() {
  test('parses the backend lock response', () {
    final lock = RecipeEditLock.fromJson(_json());

    expect(lock.recipeId, 8);
    expect(lock.lockedByUserId, 2);
    expect(lock.lockedByEmail, 'editor@example.com');
    expect(lock.acquiredAt, DateTime.utc(2026, 9, 24, 10));
    expect(lock.expiresAt, DateTime.utc(2026, 9, 24, 10, 1, 30));
    expect(lock.isHeldBy(2), isTrue);
    expect(lock.isHeldBy(3), isFalse);
  });

  test('normalises timestamp offsets to UTC', () {
    final json = _json()
      ..['acquiredAt'] = '2026-09-24T12:00:00+02:00'
      ..['expiresAt'] = '2026-09-24T12:01:30+02:00';

    final lock = RecipeEditLock.fromJson(json);

    expect(lock.acquiredAt, DateTime.utc(2026, 9, 24, 10));
    expect(lock.expiresAt.isUtc, isTrue);
  });

  test('a lock expires exactly at expiresAt', () {
    final lock = RecipeEditLock.fromJson(_json());

    expect(
      lock.isExpiredAt(DateTime.utc(2026, 9, 24, 10, 1, 29)),
      isFalse,
    );
    expect(lock.isExpiredAt(lock.expiresAt), isTrue);
  });

  final invalidValues = <String, Object?>{
    'recipeId': 0,
    'lockedByUserId': '2',
    'lockedByEmail': '',
    'acquiredAt': 'not-a-date',
    'expiresAt': '2026-09-24T10:01:30',
  };

  for (final entry in invalidValues.entries) {
    test('rejects invalid ${entry.key}', () {
      final json = _json()..[entry.key] = entry.value;

      expect(
        () => RecipeEditLock.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  }

  test('rejects expiry before acquisition', () {
    final json = _json()..['expiresAt'] = '2026-09-24T09:59:00Z';

    expect(
      () => RecipeEditLock.fromJson(json),
      throwsA(isA<FormatException>()),
    );
  });
}
