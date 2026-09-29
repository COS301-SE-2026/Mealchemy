import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../../notifications/providers/notification_realtime_provider.dart';
import '../../vault/providers/shared_vault_access_provider.dart';
import '../models/recipe_edit_lock.dart';
import 'recipe_edit_lock_provider.dart';
import 'recipe_lock_repository_provider.dart';

typedef SharedRecipeLockTarget = ({
  int vaultId,
  int recipeId,
});

final sharedRecipeLockProvider = FutureProvider.autoDispose
    .family<RecipeEditLock?, SharedRecipeLockTarget>((ref, target) async {
  final session = ref.watch(vaultSessionProvider);
  final connection = ref.watch(vaultConnectionProvider);
  final repository = ref.watch(recipeLockRepositoryProvider);
  final now = ref.watch(recipeLockNowProvider);

  if (session.restoring ||
      !session.hasValidCredential ||
      session.userId == null ||
      session.token == null ||
      connection != NetworkStatus.online) {
    throw StateError('Connect and sign in to check editing availability.');
  }

  if (target.vaultId <= 0 || target.recipeId <= 0) {
    throw StateError('Invalid shared recipe.');
  }

  var disposed = false;
  Timer? expiryTimer;

  ref.onDispose(() {
    disposed = true;
    expiryTimer?.cancel();
  });

  //events are hints, REST establishes current holder
  ref.listen(vaultLiveEventsProvider, (_, next) {
    final event = next.asData?.value;

    if (event != null &&
        event.vaultId == target.vaultId &&
        event.recipeId == target.recipeId) {
      ref.invalidateSelf();
    }
  });

  ref.listen(notificationConnectionsProvider, (_, next) {
    if (next.asData != null) {
      ref.invalidateSelf();
    }
  });

  final lock = await repository.getLock(target.recipeId);

  if (disposed) return null;

  if (lock == null) return null;

  if (lock.recipeId != target.recipeId) {
    throw const FormatException('Unexpected recipe lock response.');
  }

  final remaining = lock.expiresAt.difference(now().toUtc());

  if (remaining <= Duration.zero) {
    return null;
  }

  //expiry does not produce WebSocket event
  expiryTimer = Timer(
    remaining + const Duration(seconds: 1),
    () {
      if (!disposed) ref.invalidateSelf();
    },
  );

  return lock;
});
