import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginLockoutNowProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

class LoginLockoutNotifier extends StateNotifier<Map<String, DateTime>> {
  LoginLockoutNotifier({
    required DateTime Function() now,
  })  : _now = now,
        super(const {});

  final DateTime Function() _now;
  Timer? _timer;

  //match trimmed address submitted to backend
  String _key(String email) => email.trim();

  int remainingSeconds(String email) {
    final expiry = state[_key(email)];
    if (expiry == null) return 0;

    final milliseconds = expiry.difference(_now().toUtc()).inMilliseconds;
    if (milliseconds <= 0) return 0;

    return (milliseconds / 1000).ceil();
  }

  void record(String email, int seconds) {
    final key = _key(email);
    if (key.isEmpty) return;

    if (seconds <= 0) {
      clear(email);
      return;
    }

    state = Map.unmodifiable({
      ...state,
      key: _now().toUtc().add(Duration(seconds: seconds)),
    });

    _timer ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => refresh(),
    );
  }

  void refresh() {
    if (!mounted) return;

    final now = _now().toUtc();

    state = Map.unmodifiable({
      for (final entry in state.entries)
        if (entry.value.isAfter(now)) entry.key: entry.value,
    });

    if (state.isEmpty) {
      _timer?.cancel();
      _timer = null;
    }
  }

  void clear(String email) {
    final updated = Map<String, DateTime>.from(state)..remove(_key(email));
    state = Map.unmodifiable(updated);

    if (state.isEmpty) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

//kept in memory while the app runs and never written to device storage
final loginLockoutProvider =
    StateNotifierProvider<LoginLockoutNotifier, Map<String, DateTime>>((ref) {
  return LoginLockoutNotifier(
    now: ref.watch(loginLockoutNowProvider),
  );
});
