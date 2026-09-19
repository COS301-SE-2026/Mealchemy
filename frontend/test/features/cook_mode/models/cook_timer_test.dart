import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/models/cook_timer.dart';

void main() {
  final startedAt = DateTime.utc(2026, 9, 15, 12);
  final timer = CookTimer(
    notificationId: 42,
    recipeId: 7,
    recipeTitle: 'Tomato soup',
    stepIndex: 1,
    stepNumber: 2,
    startedAt: startedAt,
    endsAt: startedAt.add(const Duration(minutes: 20)),
  );

  test('serializes timestamps in UTC and restores timer identity', () {
    final restored = CookTimer.fromJson(timer.toJson());

    expect(restored.notificationId, 42);
    expect(restored.recipeId, 7);
    expect(restored.label, 'Tomato soup, step 2');
    expect(restored.startedAt, startedAt);
    expect(restored.endsAt, startedAt.add(const Duration(minutes: 20)));
    expect(restored.startedAt.isUtc, isTrue);
    expect(restored.endsAt.isUtc, isTrue);
  });

  test('calculates remaining time without returning negative durations', () {
    expect(
      timer.remainingAt(startedAt.add(const Duration(minutes: 5))),
      const Duration(minutes: 15),
    );
    expect(timer.remainingAt(timer.endsAt.add(const Duration(seconds: 1))),
        Duration.zero);
    expect(timer.isFinishedAt(timer.endsAt), isTrue);
  });

  test('formats compact cooking durations', () {
    expect(formatCookDuration(const Duration(hours: 1, minutes: 15)), '1h 15m');
    expect(formatCookDuration(const Duration(minutes: 4, seconds: 9)), '4m 9s');
    expect(formatCookDuration(const Duration(seconds: 45)), '45s');
  });

  test('formats countdown clocks with stable zero padding', () {
    expect(formatCookTimerClock(const Duration(minutes: 20)), '20:00');
    expect(
        formatCookTimerClock(const Duration(minutes: 4, seconds: 9)), '04:09');
    expect(
      formatCookTimerClock(const Duration(hours: 1, minutes: 2, seconds: 3)),
      '01:02:03',
    );
  });
}
