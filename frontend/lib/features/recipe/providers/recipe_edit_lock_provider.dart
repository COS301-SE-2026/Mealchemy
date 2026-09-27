import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../../vault/providers/shared_vault_access_provider.dart';
import '../models/recipe_edit_lock.dart';
import '../repositories/recipe_lock_repository.dart';
import 'recipe_lock_repository_provider.dart';

enum RecipeEditLockPhase {
  idle,
  acquiring,
  held,
  refreshing,
  blocked,
  unavailable,
  expired,
  paused,
  reloadRequired,
  releasing,
  released,
}

class RecipeEditLockState {
  const RecipeEditLockState({
    this.phase = RecipeEditLockPhase.idle,
    this.lock,
    this.message,
  });

  final RecipeEditLockPhase phase;
  final RecipeEditLock? lock;
  final String? message;

  bool get canEdit =>
      phase == RecipeEditLockPhase.held ||
      phase == RecipeEditLockPhase.refreshing;
}

//shared runtime information remains available during asynchronous cleanup
//prevents an old controller from releasing a lock using new account
class RecipeLockRuntime {
  RecipeLockRuntime({
    required this.session,
    required this.connection,
  });

  VaultSession session;
  NetworkStatus connection;
  bool active = true;
}

//serialises operations for each recipe, including cleanup from an old controller before a replacement controller acquires same recipe
class RecipeLockQueue {
  final Map<int, Future<void>> _tails = {};

  Future<T> run<T>(
    int recipeId,
    Future<T> Function() operation,
  ) {
    final previous = _tails[recipeId] ?? Future<void>.value();
    final result = previous.then((_) => operation());

    final tail = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );

    _tails[recipeId] = tail;

    unawaited(
      tail.then((_) {
        if (identical(_tails[recipeId], tail)) {
          _tails.remove(recipeId);
        }
      }),
    );

    return result;
  }
}

class RecipeEditLockNotifier extends StateNotifier<RecipeEditLockState> {
  RecipeEditLockNotifier({
    required this.recipeId,
    required RecipeLockRepository repository,
    required RecipeLockRuntime runtime,
    required RecipeLockQueue queue,
    required VaultSession session,
    required DateTime Function() now,
  })  : _repository = repository,
        _runtime = runtime,
        _queue = queue,
        _session = session,
        _now = now,
        super(const RecipeEditLockState());

  static const renewalInterval = Duration(seconds: 30);
  static const expirySafetyMargin = Duration(seconds: 5);

  final int recipeId;
  final RecipeLockRepository _repository;
  final RecipeLockRuntime _runtime;
  final RecipeLockQueue _queue;
  final VaultSession _session;
  final DateTime Function() _now;

  Timer? _renewalTimer;
  Timer? _expiryTimer;
  Future<bool>? _request;
  Future<void>? _closing;

  RecipeEditLock? _ownedLock;

  bool _stopped = false;
  bool _paused = false;
  bool _mayHoldLock = false;
  bool _needsReload = false;
  int _generation = 0;

  bool get _sameSession =>
      _runtime.active &&
      _runtime.session == _session &&
      !_session.restoring &&
      _session.hasValidCredential &&
      _session.userId != null &&
      _session.token != null;

  bool get _online => _runtime.connection == NetworkStatus.online;

  bool get _leaseIsValid {
    final lock = _ownedLock;

    return lock != null &&
        lock.isHeldBy(_session.userId ?? -1) &&
        lock.expiresAt.isAfter(
          _now().toUtc().add(expirySafetyMargin),
        );
  }

  //check immediately before starting a save, not just when rendering UI
  bool get canSave =>
      mounted &&
      !_stopped &&
      !_paused &&
      _sameSession &&
      _online &&
      !_needsReload &&
      _leaseIsValid &&
      state.canEdit;

  bool _isCurrentRequest(int generation) {
    return mounted &&
        !_stopped &&
        !_paused &&
        _sameSession &&
        generation == _generation;
  }

  Future<bool> acquire() async {
    if (!mounted || _stopped || _paused) return false;

    final pending = _request;
    if (pending != null) return pending;

    if (recipeId <= 0 || !_sameSession || !_online) {
      state = RecipeEditLockState(
        phase: RecipeEditLockPhase.unavailable,
        lock: _ownedLock,
        message: 'Connect to the internet and sign in before editing.',
      );
      return false;
    }

    final generation = ++_generation;
    final wasEditable = canSave;

    _renewalTimer?.cancel();

    state = RecipeEditLockState(
      phase: wasEditable
          ? RecipeEditLockPhase.refreshing
          : RecipeEditLockPhase.acquiring,
      lock: _ownedLock,
      message: wasEditable ? null : 'Checking recipe editing access…',
    );

    final request = _queue.run(
      recipeId,
      () => _acquire(generation),
    );
    _request = request;

    try {
      return await request;
    } finally {
      if (identical(_request, request)) {
        _request = null;
      }
    }
  }

  Future<bool> _acquire(int generation) async {
    if (!_isCurrentRequest(generation)) return false;

    if (!_online) {
      state = RecipeEditLockState(
        phase: RecipeEditLockPhase.unavailable,
        lock: _ownedLock,
        message: 'Connect to the internet before editing.',
      );
      return false;
    }

    try {
      //timeout does not prove that the backend failed to acquire the lock
      _mayHoldLock = true;

      final lock = await _repository.acquireLock(recipeId);

      if (!_isCurrentRequest(generation)) {
        await _releaseNow();
        return false;
      }

      if (lock.recipeId != recipeId ||
          !lock.isHeldBy(_session.userId!) ||
          !lock.expiresAt.isAfter(
            _now().toUtc().add(expirySafetyMargin),
          )) {
        throw const FormatException('Unexpected or expired lock response.');
      }

      final previous = _ownedLock;

      if (previous != null && previous.acquiredAt != lock.acquiredAt) {
        //another editing session may have changed recipe in between
        _needsReload = true;
      }

      _ownedLock = lock;
      _scheduleTimers(lock);

      state = RecipeEditLockState(
        phase: _needsReload
            ? RecipeEditLockPhase.reloadRequired
            : RecipeEditLockPhase.held,
        lock: lock,
        message: _needsReload
            ? 'The editing session changed. Reload the recipe before saving.'
            : null,
      );

      return canSave;
    } catch (error) {
      if (!_isCurrentRequest(generation)) {
        await _releaseNow();
        return false;
      }

      _cancelTimers();

      final status = error is DioException ? error.response?.statusCode : null;

      if (status == 409) {
        _mayHoldLock = false;
        if (_ownedLock != null) _needsReload = true;

        RecipeEditLock? otherLock;

        try {
          final result = await _repository.getLock(recipeId);

          if (result != null &&
              result.recipeId == recipeId &&
              !result.isExpiredAt(_now().toUtc()) &&
              !result.isHeldBy(_session.userId!)) {
            otherLock = result;
          }
        } catch (_) {
          //original conflict still applies if the holder lookup fails
        }

        if (!_isCurrentRequest(generation)) return false;

        state = RecipeEditLockState(
          phase: RecipeEditLockPhase.blocked,
          lock: otherLock,
          message: otherLock == null
              ? 'Someone else is editing this recipe. Try again shortly.'
              : 'Currently being edited by ${otherLock.lockedByEmail}.',
        );
      } else {
        state = RecipeEditLockState(
          phase: RecipeEditLockPhase.unavailable,
          lock: _ownedLock,
          message: switch (status) {
            401 => 'Sign in again before editing this recipe.',
            403 ||
            404 =>
              'This recipe is unavailable or you no longer have editing access.',
            _ => 'Editing access could not be confirmed. Your unsaved changes '
                'must not be submitted until access is checked again.',
          },
        );
      }

      return false;
    }
  }

  void _scheduleTimers(RecipeEditLock lock) {
    _cancelTimers();

    final remaining =
        lock.expiresAt.difference(_now().toUtc()) - expirySafetyMargin;

    _expiryTimer = Timer(remaining, () {
      if (!mounted || _stopped || _paused) return;

      ++_generation;
      _needsReload = true;
      _cancelTimers();

      state = RecipeEditLockState(
        phase: RecipeEditLockPhase.expired,
        lock: _ownedLock,
        message: 'Editing access expired. Check access and reload the recipe '
            'before saving.',
      );
    });

    _renewalTimer = Timer(renewalInterval, () {
      if (!mounted || _stopped || _paused) return;
      unawaited(acquire());
    });
  }

  //pause when connectivity becomes uncertain or the app backgrounds
  //background timers are not relied on to keep a lock alive
  void pause({
    String message = 'Editing is paused. Check access before continuing.',
  }) {
    if (!mounted || _stopped) return;

    _paused = true;
    ++_generation;
    _cancelTimers();

    state = RecipeEditLockState(
      phase: RecipeEditLockPhase.paused,
      lock: _ownedLock,
      message: message,
    );
  }

  //caller invokes this on resume or an explicit retry
  Future<bool> resume() async {
    if (!mounted || _stopped) return false;

    //finish an older request before beginning a new generation
    final pending = _request;
    if (pending != null) await pending;

    if (!mounted || _stopped) return false;

    _paused = false;
    return acquire();
  }

  //call only after fresh recipe data has been loaded while lease is held
  //supplying acquiredAt prevents a late reload acknowledging a different lease
  bool confirmReloaded({required DateTime acquiredAt}) {
    if (!mounted ||
        _stopped ||
        _paused ||
        !_sameSession ||
        !_online ||
        !_leaseIsValid ||
        !_mayHoldLock ||
        state.phase != RecipeEditLockPhase.reloadRequired ||
        _ownedLock?.acquiredAt != acquiredAt) {
      return false;
    }

    _needsReload = false;

    state = RecipeEditLockState(
      phase: RecipeEditLockPhase.held,
      lock: _ownedLock,
    );

    return true;
  }

  Future<void> close() {
    final closing = _closing;
    if (closing != null) return closing;
    if (!mounted || _stopped) return Future<void>.value();

    _stopped = true;
    ++_generation;
    _cancelTimers();

    state = RecipeEditLockState(
      phase: RecipeEditLockPhase.releasing,
      lock: _ownedLock,
    );

    final result = _queue.run<void>(recipeId, () async {
      final message = await _releaseNow();

      if (mounted) {
        state = RecipeEditLockState(
          phase: RecipeEditLockPhase.released,
          message: message,
        );
      }
    });

    _closing = result;
    return result;
  }

  Future<String?> _releaseNow() async {
    if (!_mayHoldLock) return null;

    if (!_sameSession || !_online) {
      return 'The lock could not be released immediately. '
          'It will expire automatically.';
    }

    _mayHoldLock = false;

    try {
      await _repository.releaseLock(recipeId);
      return null;
    } on DioException catch (error) {
      final status = error.response?.statusCode;

      //nothing remains for client to release
      if (status == 403 || status == 404) return null;

      return 'Lock release could not be confirmed. '
          'It will expire automatically.';
    } catch (_) {
      return 'Lock release could not be confirmed. '
          'It will expire automatically.';
    }
  }

  void _cancelTimers() {
    _renewalTimer?.cancel();
    _expiryTimer?.cancel();
    _renewalTimer = null;
    _expiryTimer = null;
  }

  @override
  void dispose() {
    _stopped = true;
    ++_generation;
    _cancelTimers();

    if (_closing == null) {
      unawaited(
        _queue.run<void>(recipeId, () async {
          await _releaseNow();
        }),
      );
    }

    super.dispose();
  }
}

final recipeLockNowProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

final recipeLockQueueProvider = Provider<RecipeLockQueue>((ref) {
  return RecipeLockQueue();
});

final recipeLockRuntimeProvider = Provider<RecipeLockRuntime>((ref) {
  final runtime = RecipeLockRuntime(
    session: ref.read(vaultSessionProvider),
    connection: ref.read(vaultConnectionProvider),
  );

  ref.listen(vaultSessionProvider, (_, next) {
    runtime.session = next;
  });

  ref.listen(vaultConnectionProvider, (_, next) {
    runtime.connection = next;
  });

  ref.onDispose(() => runtime.active = false);

  return runtime;
});

final recipeEditLockProvider = StateNotifierProvider.autoDispose
    .family<RecipeEditLockNotifier, RecipeEditLockState, int>((ref, recipeId) {
  final notifier = RecipeEditLockNotifier(
    recipeId: recipeId,
    repository: ref.watch(recipeLockRepositoryProvider),
    runtime: ref.watch(recipeLockRuntimeProvider),
    queue: ref.watch(recipeLockQueueProvider),
    session: ref.watch(vaultSessionProvider),
    now: ref.watch(recipeLockNowProvider),
  );

  ref.listen(vaultConnectionProvider, (_, next) {
    if (next != NetworkStatus.online) {
      notifier.pause(
        message: 'Connection interrupted. Check editing access '
            'before continuing.',
      );
    }
  });

  return notifier;
});
