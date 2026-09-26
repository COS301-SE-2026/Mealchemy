import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/repositories/mock_recipe_lock_repository.dart';

Matcher _hasStatus(int status) {
  return isA<DioException>().having(
    (error) => error.response?.statusCode,
    'status code',
    status,
  );
}

void main() {
  late DateTime now;
  late MockRecipeLockStore store;
  late MockRecipeLockRepository first;
  late MockRecipeLockRepository second;
  late bool firstCanEdit;
  late bool firstCanAccess;

  setUp(() {
    now = DateTime.utc(2026, 9, 24, 10);
    store = MockRecipeLockStore();
    firstCanEdit = true;
    firstCanAccess = true;

    first = MockRecipeLockRepository(
      store: store,
      userId: 1,
      email: 'sofia@example.com',
      canAccess: (_) => firstCanAccess,
      canEdit: (_) => firstCanEdit,
      now: () => now,
    );

    second = MockRecipeLockRepository(
      store: store,
      userId: 2,
      email: 'gabriela@example.com',
      canAccess: (_) => true,
      canEdit: (_) => true,
      now: () => now,
    );
  });

  test('an unlocked recipe returns null', () async {
    expect(await first.getLock(8), isNull);
  });

  test('acquisition lasts 90 seconds', () async {
    final lock = await first.acquireLock(8);

    expect(lock.lockedByUserId, 1);
    expect(lock.expiresAt, now.add(const Duration(seconds: 90)));
  });

  test('refresh extends expiry and preserves acquisition time', () async {
    final original = await first.acquireLock(8);
    now = now.add(const Duration(seconds: 30));

    final refreshed = await first.acquireLock(8);

    expect(refreshed.acquiredAt, original.acquiredAt);
    expect(refreshed.expiresAt, now.add(const Duration(seconds: 90)));
  });

  test('another user cannot acquire a live lock', () async {
    await first.acquireLock(8);

    await expectLater(
      second.acquireLock(8),
      throwsA(_hasStatus(409)),
    );
  });

  test('another user can acquire after expiry', () async {
    await first.acquireLock(8);
    now = now.add(const Duration(seconds: 90));

    expect(await first.getLock(8), isNull);

    final replacement = await second.acquireLock(8);

    expect(replacement.lockedByUserId, 2);
    expect(replacement.acquiredAt, now);
  });

  test('the holder can release their lock', () async {
    await first.acquireLock(8);
    await first.releaseLock(8);

    expect(await second.getLock(8), isNull);
  });

  test('another user cannot release the lock', () async {
    await first.acquireLock(8);

    await expectLater(
      second.releaseLock(8),
      throwsA(_hasStatus(403)),
    );

    expect((await first.getLock(8))!.lockedByUserId, 1);
  });

  test('releasing a missing lock returns 404', () async {
    await expectLater(
      first.releaseLock(8),
      throwsA(_hasStatus(404)),
    );
  });

  test('a role change prevents renewal', () async {
    await first.acquireLock(8);
    firstCanEdit = false;

    await expectLater(
      first.acquireLock(8),
      throwsA(_hasStatus(404)),
    );

    //current holder can still release if recipe access remains
    await first.releaseLock(8);
    expect(await first.getLock(8), isNull);
  });

  test('loss of recipe access prevents lock operations', () async {
    await first.acquireLock(8);
    firstCanAccess = false;

    await expectLater(
      first.getLock(8),
      throwsA(_hasStatus(404)),
    );
    await expectLater(
      first.acquireLock(8),
      throwsA(_hasStatus(404)),
    );
    await expectLater(
      first.releaseLock(8),
      throwsA(_hasStatus(404)),
    );
  });

  test('locks on different recipes are independent', () async {
    await first.acquireLock(8);
    await second.acquireLock(9);

    expect((await first.getLock(8))!.lockedByUserId, 1);
    expect((await first.getLock(9))!.lockedByUserId, 2);
  });
}
