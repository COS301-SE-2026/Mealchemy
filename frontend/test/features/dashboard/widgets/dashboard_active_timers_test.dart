import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/models/cook_timer.dart';
import 'package:mealchemy/features/dashboard/widgets/dashboard_active_timers.dart';

void main() {
  final now = DateTime.utc(2026, 9, 19, 12);

  CookTimer timer({
    required int notificationId,
    required int recipeId,
    required String title,
    required int stepIndex,
  }) {
    return CookTimer(
      notificationId: notificationId,
      recipeId: recipeId,
      recipeTitle: title,
      stepIndex: stepIndex,
      stepNumber: stepIndex + 1,
      startedAt: now,
      endsAt: now.add(const Duration(minutes: 20)),
    );
  }

  testWidgets('shows active timers and forwards the selected timer',
      (tester) async {
    final first = timer(
      notificationId: 41,
      recipeId: 7,
      title: 'Weeknight Pasta',
      stepIndex: 1,
    );
    final second = timer(
      notificationId: 42,
      recipeId: 8,
      title: 'Tomato Soup',
      stepIndex: 2,
    );
    CookTimer? selected;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DashboardActiveTimers(
          timers: [first, second],
          now: now,
          onTimerTap: (timer) => selected = timer,
        ),
      ),
    ));

    expect(find.text('Active cooking timers'), findsOneWidget);
    expect(find.text('Weeknight Pasta'), findsOneWidget);
    expect(find.text('Tomato Soup'), findsOneWidget);
    expect(find.text('Step 2'), findsOneWidget);
    expect(find.text('Step 3'), findsOneWidget);

    await tester.tap(find.byKey(const Key('dashboard-timer-42')));
    expect(selected, same(second));
  });

  testWidgets('renders nothing when there are no active timers',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DashboardActiveTimers(
          timers: const [],
          now: now,
          onTimerTap: (_) {},
        ),
      ),
    ));

    expect(find.byKey(const Key('dashboard-active-timers')), findsNothing);
  });
}
