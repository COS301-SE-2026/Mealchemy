import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/notifications/models/vault_live_event.dart';
import 'package:mealchemy/features/notifications/providers/notification_realtime_provider.dart';
import 'package:mealchemy/features/recipe/models/recipe_edit_lock.dart';
import 'package:mealchemy/features/recipe/providers/recipe_edit_lock_provider.dart';
import 'package:mealchemy/features/recipe/providers/recipe_lock_repository_provider.dart';
import 'package:mealchemy/features/recipe/providers/shared_recipe_lock_provider.dart';
import 'package:mealchemy/features/recipe/repositories/recipe_lock_repository.dart';
import 'package:mealchemy/features/vault/providers/shared_vault_access_provider.dart';

class _Locks implements RecipeLockRepository {
  RecipeEditLock? current;
  int reads = 0;

  @override
  Future<RecipeEditLock?> getLock(int recipeId) async {
    reads++;
    return current;
  }

  @override
  Future<RecipeEditLock> acquireLock(int recipeId) {
    throw StateError('The viewing provider must not acquire locks.');
  }

  @override
  Future<void> releaseLock(int recipeId) {
    throw StateError('The viewing provider must not release locks.');
  }
}

void main() {
  testWidgets('loads REST state and rechecks relevant events and expiry',
      (tester) async {
    const target = (vaultId: 2, recipeId: 99);
    var now = DateTime.utc(2026, 9, 27);

    final locks = _Locks();
    final events = StreamController<VaultLiveEvent>.broadcast();
    final connections = StreamController<int>.broadcast();

    final container = ProviderContainer(
      overrides: [
        vaultSessionProvider.overrideWithValue((
          userId: 1,
          token: 'test-token',
          restoring: false,
          hasValidCredential: true,
        )),
        vaultConnectionProvider.overrideWithValue(NetworkStatus.online),
        recipeLockRepositoryProvider.overrideWithValue(locks),
        recipeLockNowProvider.overrideWithValue(() => now),
        vaultLiveEventsProvider.overrideWith((ref) => events.stream),
        notificationConnectionsProvider.overrideWith(
          (ref) => connections.stream,
        ),
      ],
    );

    final subscription = container.listen(
      sharedRecipeLockProvider(target),
      (_, __) {},
      fireImmediately: true,
    );

    try {
      await tester.pump();

      expect(locks.reads, 1);
      expect(
        container.read(sharedRecipeLockProvider(target)).requireValue,
        isNull,
      );

      events.add(
        const VaultLiveEvent(
          rawType: 'LOCK_ACQUIRED',
          vaultId: 2,
          recipeId: 100,
          actorUserId: 9,
        ),
      );

      await tester.pump();
      expect(locks.reads, 1);

      locks.current = RecipeEditLock(
        recipeId: 99,
        lockedByUserId: 9,
        lockedByEmail: 'gabriela@example.com',
        acquiredAt: now,
        expiresAt: now.add(const Duration(seconds: 90)),
      );

      events.add(
        const VaultLiveEvent(
          rawType: 'LOCK_ACQUIRED',
          vaultId: 2,
          recipeId: 99,
          actorUserId: 9,
        ),
      );

      await tester.pump();
      await container.read(sharedRecipeLockProvider(target).future);

      expect(locks.reads, 2);
      expect(
        container
            .read(sharedRecipeLockProvider(target))
            .requireValue!
            .lockedByUserId,
        9,
      );

      connections.add(1);
      await tester.pump();
      await container.read(sharedRecipeLockProvider(target).future);

      expect(locks.reads, 3);

      locks.current = null;
      now = now.add(const Duration(seconds: 91));

      await tester.pump(const Duration(seconds: 91));
      await container.read(sharedRecipeLockProvider(target).future);

      expect(locks.reads, 4);
      expect(
        container.read(sharedRecipeLockProvider(target)).requireValue,
        isNull,
      );
    } finally {
      subscription.close();
      container.dispose();

      // Explicitly advance the fake clock to drain scheduled timers.
      await tester.pump(Duration.zero);

      await tester.runAsync(() async {
        await events.close();
        await connections.close();
      });

      await tester.pump(Duration.zero);
    }
  });
}
