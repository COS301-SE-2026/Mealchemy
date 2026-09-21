import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/models/cook_timer.dart';
import 'package:mealchemy/features/cook_mode/providers/cook_timer_provider.dart';
import 'package:mealchemy/features/cook_mode/widgets/cook_timer_controls.dart';

void main() {
  testWidgets('starts a detected timer from the compact control',
      (tester) async {
    Duration? started;
    final now = DateTime.utc(2026, 9, 15, 12);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CookTimerControls(
          state: CookTimerState(now: now, isInitialized: true),
          suggestedDuration: const Duration(minutes: 20),
          onStart: (duration) async => started = duration,
          onCancel: (_) async {},
        ),
      ),
    ));

    expect(find.text('Start 20m timer'), findsOneWidget);
    await tester.tap(find.byKey(const Key('start-suggested-timer')));
    await tester.pump();

    expect(started, const Duration(minutes: 20));
  });

  testWidgets('shows active timers and allows cancellation', (tester) async {
    CookTimer? cancelled;
    final now = DateTime.utc(2026, 9, 15, 12);
    final timer = CookTimer(
      notificationId: 7,
      recipeId: 3,
      recipeTitle: 'Pasta',
      stepIndex: 1,
      stepNumber: 2,
      startedAt: now,
      endsAt: now.add(const Duration(minutes: 5)),
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CookTimerControls(
          state: CookTimerState(
            now: now,
            isInitialized: true,
            timers: [timer],
          ),
          suggestedDuration: null,
          onStart: (_) async {},
          onCancel: (value) async => cancelled = value,
        ),
      ),
    ));

    expect(find.text('1 active timer'), findsOneWidget);
    await tester.tap(find.byKey(const Key('manage-cook-timers')));
    await tester.pumpAndSettle();
    expect(find.text('Pasta, step 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Cancel Pasta, step 2'));
    await tester.pumpAndSettle();
    expect(cancelled, timer);
  });
}
