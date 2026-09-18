import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cook_timer.dart';
import '../services/cook_timer_notification_service.dart';
import '../services/cook_timer_store.dart';

class CookTimerState {
  const CookTimerState({
    this.isInitialized = false,
    this.timers = const [],
    required this.now,
    this.warningMessage,
  });

  final bool isInitialized;
  final List<CookTimer> timers;
  final DateTime now;
  final String? warningMessage;

  List<CookTimer> get activeTimers {
    final active = timers.where((timer) => !timer.isFinishedAt(now)).toList();
    active.sort((first, second) => first.endsAt.compareTo(second.endsAt));
    return active;
  }

  CookTimerState copyWith({
    bool? isInitialized,
    List<CookTimer>? timers,
    DateTime? now,
    String? warningMessage,
    bool clearWarning = false,
  }) {
    return CookTimerState(
      isInitialized: isInitialized ?? this.isInitialized,
      timers: timers ?? this.timers,
      now: now ?? this.now,
      warningMessage:
          clearWarning ? null : warningMessage ?? this.warningMessage,
    );
  }
}

class CookTimerController extends StateNotifier<CookTimerState> {
  CookTimerController({
    required CookTimerStore store,
    required CookTimerNotificationService notifications,
    required int? userId,
    DateTime Function()? now,
    bool startTicker = true,
  })  : _store = store,
        _notifications = notifications,
        _userId = userId,
        _now = now ?? DateTime.now,
        super(CookTimerState(now: (now ?? DateTime.now)().toUtc())) {
    if (startTicker) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => refresh());
    }
  }

  final CookTimerStore _store;
  final CookTimerNotificationService _notifications;
  final int? _userId;
  final DateTime Function() _now;
  Timer? _ticker;
  Future<void>? _initializing;

  Future<void> initialize() {
    return _initializing ??= _initialize();
  }

  Future<void> _initialize() async {
    var timers = <CookTimer>[];
    final userId = _userId;
    if (userId != null) {
      try {
        timers = await _store.readAll(userId);
        timers = timers
            .where((timer) => !timer.isFinishedAt(_now()))
            .toList(growable: false);
        await _store.saveAll(userId, timers);
      } catch (_) {
        if (mounted) {
          state = state.copyWith(
            warningMessage: 'Saved timers could not be restored.',
          );
        }
      }
    }

    if (!mounted) return;
    state = state.copyWith(
      isInitialized: true,
      timers: timers,
      now: _now().toUtc(),
    );
  }

  Future<CookTimer> start({
    required int recipeId,
    required String recipeTitle,
    required int stepIndex,
    required int stepNumber,
    required Duration duration,
  }) async {
    await initialize();
    final startedAt = _now().toUtc();
    final timer = CookTimer(
      notificationId: _nextNotificationId(startedAt),
      recipeId: recipeId,
      recipeTitle: recipeTitle,
      stepIndex: stepIndex,
      stepNumber: stepNumber,
      startedAt: startedAt,
      endsAt: startedAt.add(duration),
    );
    state = state.copyWith(
      timers: [...state.timers, timer],
      now: startedAt,
      clearWarning: true,
    );
    await _persist();

    final alertStatus = await _notifications.schedule(timer);
    if (mounted) {
      state = state.copyWith(warningMessage: _warningFor(alertStatus));
    }
    return timer;
  }

  Future<void> cancel(CookTimer timer) async {
    state = state.copyWith(
      timers: state.timers
          .where(
              (candidate) => candidate.notificationId != timer.notificationId)
          .toList(growable: false),
      clearWarning: true,
    );
    await _persist();
    try {
      await _notifications.cancel(timer.notificationId);
    } catch (_) {
      if (mounted) {
        state = state.copyWith(
          warningMessage: 'The timer alert could not be cancelled.',
        );
      }
    }
  }

  void refresh() {
    if (!mounted) return;
    state = state.copyWith(now: _now().toUtc());
  }

  void clearWarning() {
    state = state.copyWith(clearWarning: true);
  }

  int _nextNotificationId(DateTime now) {
    var candidate = now.microsecondsSinceEpoch.remainder(0x7fffffff);
    final used = state.timers.map((timer) => timer.notificationId).toSet();
    while (used.contains(candidate)) {
      candidate = (candidate + 1).remainder(0x7fffffff);
    }
    return candidate;
  }

  Future<void> _persist() async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await _store.saveAll(userId, state.timers);
    } catch (_) {
      if (mounted) {
        state = state.copyWith(
          warningMessage: 'Timers may not resume after the app closes.',
        );
      }
    }
  }

  String? _warningFor(CookTimerAlertStatus status) {
    return switch (status) {
      CookTimerAlertStatus.scheduled => null,
      CookTimerAlertStatus.notificationsDenied =>
        'Timer started, but notification access is off.',
      CookTimerAlertStatus.exactAlarmDenied =>
        'Timer started, but exact background alerts are off.',
      CookTimerAlertStatus.unsupported =>
        'Timer started. Background alerts are unavailable here.',
      CookTimerAlertStatus.failed =>
        'Timer started, but its background alert could not be scheduled.',
    };
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final cookTimerStoreProvider = Provider<CookTimerStore>((ref) {
  return FileCookTimerStore();
});

final cookTimerNotificationServiceProvider =
    Provider<CookTimerNotificationService>((ref) {
  return FlutterLocalNotificationsCookTimerService();
});

final cookTimerControllerProvider = StateNotifierProvider.autoDispose
    .family<CookTimerController, CookTimerState, int?>((ref, userId) {
  final controller = CookTimerController(
    store: ref.watch(cookTimerStoreProvider),
    notifications: ref.watch(cookTimerNotificationServiceProvider),
    userId: userId,
  );
  unawaited(controller.initialize());
  return controller;
});
