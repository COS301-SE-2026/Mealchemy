import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/recipe/models/recipe_edit_lock.dart';
import 'package:mealchemy/features/recipe/providers/recipe_edit_lock_provider.dart';
import 'package:mealchemy/features/recipe/repositories/mock_recipe_lock_repository.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_lock_repository.dart';
import 'package:mealchemy/features/vault/providers/shared_vault_access_provider.dart';

VaultSession _session([int userId = 1]) => (
      userId: userId,
      token: 'token-$userId',
      restoring: false,
      hasValidCredential: true,
    );

DioException _error(int status) {
  final request = RequestOptions(path: '/recipes/8/lock');

  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: request,
      statusCode: status,
    ),
  );
}

class _Repository implements RecipeLockRepository {
  _Repository(this.delegate);

  final RecipeLockRepository delegate;

  int acquisitions = 0;
  int releases = 0;
  int lookups = 0;

  Future<RecipeEditLock> Function()? acquireResponse;
  Future<void> Function()? releaseResponse;

  @override
  Future<RecipeEditLock> acquireLock(int recipeId) async {
    acquisitions++;
    final response = acquireResponse;
    return response == null
        ? await delegate.acquireLock(recipeId)
        : await response();
  }

  @override
  Future<RecipeEditLock?> getLock(int recipeId) async {
    lookups++;
    return delegate.getLock(recipeId);
  }

  @override
  Future<void> releaseLock(int recipeId) async {
    releases++;
    final response = releaseResponse;

    if (response != null) {
      await response();
    } else {
      await delegate.releaseLock(recipeId);
    }
  }
}

class _Fixture {
  _Fixture() {
    repository = _Repository(
      MockRecipeLockRepository(
        store: store,
        userId: 1,
        email: 'sofia@example.com',
        canAccess: (_) => true,
        canEdit: (_) => true,
        now: () => now,
      ),
    );

    controller = createController();
  }

  DateTime now = DateTime.utc(2026, 9, 25, 10);

  final store = MockRecipeLockStore();
  final queue = RecipeLockQueue();

  final runtime = RecipeLockRuntime(
    session: _session(),
    connection: NetworkStatus.online,
  );

  late final _Repository repository;
  late final RecipeEditLockNotifier controller;

  RecipeEditLockNotifier createController() {
    return RecipeEditLockNotifier(
      recipeId: 8,
      repository: repository,
      runtime: runtime,
      queue: queue,
      session: _session(),
      now: () => now,
    );
  }

  Future<void> advance(
    WidgetTester tester,
    Duration duration,
  ) async {
    now = now.add(duration);
    await tester.pump(duration);
  }

  MockRecipeLockRepository otherUser() {
    return MockRecipeLockRepository(
      store: store,
      userId: 2,
      email: 'gabriela@example.com',
      canAccess: (_) => true,
      canEdit: (_) => true,
      now: () => now,
    );
  }
}

void main() {
  void lockTest(
    String description,
    Future<void> Function(WidgetTester tester, _Fixture fixture) body,
  ) {
    testWidgets(description, (tester) async {
      final fixture = _Fixture();

      try {
        await body(tester, fixture);
      } finally {
        await fixture.controller.close();
        fixture.controller.dispose();
        await tester.pump();
      }
    });
  }

  lockTest('acquires the lock before allowing saves', (tester, f) async {
    expect(f.controller.canSave, isFalse);

    expect(await f.controller.acquire(), isTrue);

    expect(f.repository.acquisitions, 1);
    expect(f.controller.state.phase, RecipeEditLockPhase.held);
    expect(f.controller.canSave, isTrue);
  });

  lockTest('renews after 30 seconds and preserves acquiredAt',
      (tester, f) async {
    await f.controller.acquire();
    final original = f.controller.state.lock!;

    await f.advance(tester, const Duration(seconds: 30));

    expect(f.repository.acquisitions, 2);
    expect(f.controller.state.lock!.acquiredAt, original.acquiredAt);
    expect(
      f.controller.state.lock!.expiresAt,
      f.now.add(const Duration(seconds: 90)),
    );
    expect(f.controller.canSave, isTrue);
  });

  lockTest('concurrent callers share one acquisition', (tester, f) async {
    final pending = Completer<RecipeEditLock>();
    f.repository.acquireResponse = () => pending.future;

    final first = f.controller.acquire();
    final second = f.controller.acquire();

    await tester.pump();

    expect(f.repository.acquisitions, 1);
    expect(f.controller.canSave, isFalse);

    pending.complete(
      RecipeEditLock(
        recipeId: 8,
        lockedByUserId: 1,
        lockedByEmail: 'sofia@example.com',
        acquiredAt: f.now,
        expiresAt: f.now.add(const Duration(seconds: 90)),
      ),
    );

    expect(await first, isTrue);
    expect(await second, isTrue);
  });

  lockTest('a slow renewal cannot keep saving enabled past expiry',
      (tester, f) async {
    await f.controller.acquire();
    final original = f.controller.state.lock!;
    final pending = Completer<RecipeEditLock>();

    f.repository.acquireResponse = () => pending.future;

    await f.advance(tester, const Duration(seconds: 30));

    expect(f.repository.acquisitions, 2);
    expect(f.controller.state.phase, RecipeEditLockPhase.refreshing);
    expect(f.controller.canSave, isTrue);

    await f.advance(tester, const Duration(seconds: 55));

    expect(f.controller.state.phase, RecipeEditLockPhase.expired);
    expect(f.controller.canSave, isFalse);
    expect(f.repository.acquisitions, 2);

    pending.complete(
      RecipeEditLock(
        recipeId: 8,
        lockedByUserId: 1,
        lockedByEmail: 'sofia@example.com',
        acquiredAt: original.acquiredAt,
        expiresAt: f.now.add(const Duration(seconds: 90)),
      ),
    );

    await tester.pump();

    expect(f.controller.canSave, isFalse);
    expect(f.repository.releases, 1);
  });

  lockTest('conflict shows the other editor and does not allow saving',
      (tester, f) async {
    await f.otherUser().acquireLock(8);

    expect(await f.controller.acquire(), isFalse);

    expect(f.controller.state.phase, RecipeEditLockPhase.blocked);
    expect(
      f.controller.state.message,
      contains('gabriela@example.com'),
    );
    expect(f.repository.lookups, 1);
    expect(f.controller.canSave, isFalse);

    await f.advance(tester, const Duration(seconds: 30));

    expect(f.repository.acquisitions, 1);
  });

  for (final status in [401, 403, 404]) {
    lockTest('HTTP $status stops editing and automatic renewal',
        (tester, f) async {
      await f.controller.acquire();

      f.repository.acquireResponse = () async => throw _error(status);

      await f.advance(tester, const Duration(seconds: 30));

      expect(f.controller.state.phase, RecipeEditLockPhase.unavailable);
      expect(f.controller.canSave, isFalse);

      await f.advance(tester, const Duration(seconds: 60));

      expect(f.repository.acquisitions, 2);
    });
  }

  lockTest('renewal network failure disables saving', (tester, f) async {
    await f.controller.acquire();

    f.repository.acquireResponse = () async {
      throw DioException(
        requestOptions: RequestOptions(path: '/recipes/8/lock'),
        type: DioExceptionType.connectionTimeout,
      );
    };

    await f.advance(tester, const Duration(seconds: 30));

    expect(f.controller.state.phase, RecipeEditLockPhase.unavailable);
    expect(f.controller.canSave, isFalse);
  });

  lockTest('pause stops renewal until access is checked again',
      (tester, f) async {
    await f.controller.acquire();

    f.controller.pause();
    await f.advance(tester, const Duration(seconds: 30));

    expect(f.repository.acquisitions, 1);
    expect(f.controller.canSave, isFalse);

    expect(await f.controller.resume(), isTrue);
    expect(f.repository.acquisitions, 2);
  });

  lockTest('reacquiring an expired session requires a recipe reload',
      (tester, f) async {
    await f.controller.acquire();

    f.controller.pause();
    await f.advance(tester, const Duration(seconds: 95));

    expect(await f.controller.resume(), isFalse);
    expect(
      f.controller.state.phase,
      RecipeEditLockPhase.reloadRequired,
    );
    expect(f.controller.canSave, isFalse);

    final acquiredAt = f.controller.state.lock!.acquiredAt;

    expect(
      f.controller.confirmReloaded(
        acquiredAt: acquiredAt.subtract(const Duration(seconds: 1)),
      ),
      isFalse,
    );

    expect(
      f.controller.confirmReloaded(acquiredAt: acquiredAt),
      isTrue,
    );
    expect(f.controller.canSave, isTrue);
  });

  for (final connection in [
    NetworkStatus.offline,
    NetworkStatus.checking,
  ]) {
    lockTest('$connection prevents acquisition', (tester, f) async {
      f.runtime.connection = connection;

      expect(await f.controller.acquire(), isFalse);
      expect(f.repository.acquisitions, 0);
      expect(f.controller.canSave, isFalse);
    });
  }

  lockTest('connection restoration alone does not restore editing',
      (tester, f) async {
    await f.controller.acquire();

    f.runtime.connection = NetworkStatus.offline;
    f.controller.pause();

    expect(f.controller.canSave, isFalse);

    f.runtime.connection = NetworkStatus.online;

    expect(f.controller.canSave, isFalse);
    expect(await f.controller.resume(), isTrue);
  });

  lockTest('close releases the lock and stops timers', (tester, f) async {
    await f.controller.acquire();
    await f.controller.close();

    expect(f.repository.releases, 1);
    expect(f.controller.state.phase, RecipeEditLockPhase.released);
    expect(f.controller.canSave, isFalse);

    await f.advance(tester, const Duration(minutes: 2));

    expect(f.repository.acquisitions, 1);
  });

  lockTest('closing during acquisition cleans up the late lock',
      (tester, f) async {
    final pending = Completer<RecipeEditLock>();
    f.repository.acquireResponse = () => pending.future;

    final acquiring = f.controller.acquire();
    await tester.pump();

    final closing = f.controller.close();

    pending.complete(
      RecipeEditLock(
        recipeId: 8,
        lockedByUserId: 1,
        lockedByEmail: 'sofia@example.com',
        acquiredAt: f.now,
        expiresAt: f.now.add(const Duration(seconds: 90)),
      ),
    );

    expect(await acquiring, isFalse);
    await closing;

    expect(f.repository.releases, 1);
    expect(f.controller.canSave, isFalse);
  });

  lockTest('late responses cannot grant access after an account change',
      (tester, f) async {
    final pending = Completer<RecipeEditLock>();
    f.repository.acquireResponse = () => pending.future;

    final acquiring = f.controller.acquire();
    await tester.pump();

    f.runtime.session = _session(2);

    pending.complete(
      RecipeEditLock(
        recipeId: 8,
        lockedByUserId: 1,
        lockedByEmail: 'sofia@example.com',
        acquiredAt: f.now,
        expiresAt: f.now.add(const Duration(seconds: 90)),
      ),
    );

    expect(await acquiring, isFalse);
    expect(f.controller.canSave, isFalse);

    //don't send DELETE using replacement account's credentials
    expect(f.repository.releases, 0);
  });

  for (final status in [403, 404]) {
    lockTest('release HTTP $status is treated as finished cleanup',
        (tester, f) async {
      await f.controller.acquire();

      f.repository.releaseResponse = () async => throw _error(status);

      await f.controller.close();

      expect(f.controller.state.phase, RecipeEditLockPhase.released);
      expect(f.controller.state.message, isNull);
    });
  }

  lockTest('failed release reports that expiry will clean up',
      (tester, f) async {
    await f.controller.acquire();

    f.repository.releaseResponse = () async => throw _error(500);

    await f.controller.close();

    expect(
      f.controller.state.message,
      contains('expire automatically'),
    );
    expect(f.controller.canSave, isFalse);
  });

  lockTest('old cleanup finishes before a replacement acquisition',
      (tester, f) async {
    await f.controller.acquire();

    final pendingRelease = Completer<void>();

    f.repository.releaseResponse = () async {
      await pendingRelease.future;
      await f.repository.delegate.releaseLock(8);
    };

    final closing = f.controller.close();
    await tester.pump();

    final replacement = f.createController();

    try {
      final acquiring = replacement.acquire();
      await tester.pump();

      expect(f.repository.acquisitions, 1);

      pendingRelease.complete();
      await closing;

      expect(await acquiring, isTrue);
      expect(f.repository.acquisitions, 2);
    } finally {
      await replacement.close();
      replacement.dispose();
    }
  });
}
