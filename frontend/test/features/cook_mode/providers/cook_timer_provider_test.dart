import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/models/cook_timer.dart';
import 'package:mealchemy/features/cook_mode/providers/cook_timer_provider.dart';
import 'package:mealchemy/features/cook_mode/services/cook_timer_notification_service.dart';
import 'package:mealchemy/features/cook_mode/services/cook_timer_store.dart';

class _FakeTimerStore implements CookTimerStore {
  List<CookTimer> timers = [];
  int saveCalls = 0;

  @override
  Future<List<CookTimer>> readAll(int userId) async => List.of(timers);

  @override
  Future<void> saveAll(int userId, List<CookTimer> timers) async {
    saveCalls++;
    this.timers = List.of(timers);
  }
}

class _FakeNotifications implements CookTimerNotificationService {
  CookTimerAlertStatus status = CookTimerAlertStatus.scheduled;
  final List<CookTimer> scheduled = [];
  final List<int> cancelled = [];

  @override
  Future<CookTimerAlertStatus> schedule(CookTimer timer) async {
    scheduled.add(timer);
    return status;
  }

  @override
  Future<void> cancel(int notificationId) async {
    cancelled.add(notificationId);
  }
}

CookTimer _savedTimer(DateTime start, Duration duration) => CookTimer(
      notificationId: 5,
      recipeId: 7,
      recipeTitle: 'Soup',
      stepIndex: 0,
      stepNumber: 1,
      startedAt: start,
      endsAt: start.add(duration),
    );

void main() {
  late DateTime now;
  late _FakeTimerStore store;
  late _FakeNotifications notifications;
  late CookTimerController controller;

  setUp(() {
    now = DateTime.utc(2026, 9, 15, 12);
    store = _FakeTimerStore();
    notifications = _FakeNotifications();
    controller = CookTimerController(
      store: store,
      notifications: notifications,
      userId: 21,
      now: () => now,
      startTicker: false,
    );
  });

  tearDown(() => controller.dispose());

  test('restores active timers and removes expired timers', () async {
    store.timers = [
      _savedTimer(now.subtract(const Duration(minutes: 20)),
          const Duration(minutes: 10)),
      _savedTimer(now, const Duration(minutes: 10)),
    ];

    await controller.initialize();

    expect(controller.state.isInitialized, isTrue);
    expect(controller.state.activeTimers, hasLength(1));
    expect(store.timers, hasLength(1));
  });

  test('starts, persists, schedules, ticks, and cancels a timer', () async {
    await controller.initialize();
    final timer = await controller.start(
      recipeId: 7,
      recipeTitle: 'Soup',
      stepIndex: 1,
      stepNumber: 2,
      duration: const Duration(minutes: 5),
    );

    expect(controller.state.activeTimers, [timer]);
    expect(store.timers, [timer]);
    expect(notifications.scheduled, [timer]);

    now = now.add(const Duration(minutes: 6));
    controller.refresh();
    expect(controller.state.activeTimers, isEmpty);

    await controller.cancel(timer);
    expect(controller.state.timers, isEmpty);
    expect(notifications.cancelled, [timer.notificationId]);
  });

  test('keeps an in-app timer when exact background alerts are denied',
      () async {
    notifications.status = CookTimerAlertStatus.exactAlarmDenied;
    await controller.start(
      recipeId: 7,
      recipeTitle: 'Soup',
      stepIndex: 0,
      stepNumber: 1,
      duration: const Duration(minutes: 5),
    );

    expect(controller.state.activeTimers, hasLength(1));
    expect(controller.state.warningMessage, contains('exact background'));
  });
}
