import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/models/cook_timer.dart';
import 'package:mealchemy/features/cook_mode/services/cook_timer_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('contains native plugin failures and reports the fallback status',
      () async {
    final now = DateTime.utc(2026, 9, 15, 12);
    final service = FlutterLocalNotificationsCookTimerService();
    final timer = CookTimer(
      notificationId: 1,
      recipeId: 7,
      recipeTitle: 'Soup',
      stepIndex: 0,
      stepNumber: 1,
      startedAt: now,
      endsAt: now.add(const Duration(minutes: 1)),
    );

    expect(await service.schedule(timer), CookTimerAlertStatus.failed);
  });
}
