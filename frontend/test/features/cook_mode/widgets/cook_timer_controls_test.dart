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
          onStart: (duration, _) async => started = duration,
          onPause: (_) async {},
          onResume: (_) async {},
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
          onStart: (_, __) async {},
          onPause: (_) async {},
          onResume: (_) async {},
          onCancel: (value) async => cancelled = value,
        ),
      ),
    ));

    expect(find.text('1 active timer'), findsOneWidget);
    await tester.tap(find.byKey(const Key('manage-cook-timers')));
    await tester.pumpAndSettle();
    expect(find.text('Timer'), findsOneWidget);
    expect(find.text('5m remaining - Step 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Cancel Pasta, step 2'));
    await tester.pumpAndSettle();
    expect(cancelled, timer);
  });

  testWidgets('starts a manually named timer with a typed duration',
      (tester) async {
    Duration? started;
    String? name;
    final now = DateTime.utc(2026, 9, 15, 12);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CookTimerControls(
          state: CookTimerState(now: now, isInitialized: true),
          suggestedDuration: null,
          onStart: (duration, timerName) async {
            started = duration;
            name = timerName;
          },
          onPause: (_) async {},
          onResume: (_) async {},
          onCancel: (_) async {},
        ),
      ),
    ));

    await tester.tap(find.byKey(const Key('manage-cook-timers')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('manual-timer-name')),
        matching: find.byType(TextField),
      ),
      'Pasta sauce',
    );
    await tester.enterText(
      find.byKey(const Key('manual-timer-duration-input')),
      '12',
    );
    await tester.tap(find.byKey(const Key('start-manual-timer')));
    await tester.pumpAndSettle();

    expect(started, const Duration(minutes: 12));
    expect(name, 'Pasta sauce');
  });

  testWidgets('pauses and resumes timers from the active list', (tester) async {
    CookTimer? paused;
    CookTimer? resumed;
    final now = DateTime.utc(2026, 9, 15, 12);
    final runningTimer = CookTimer(
      notificationId: 8,
      recipeId: 3,
      recipeTitle: 'Pasta',
      stepIndex: 0,
      stepNumber: 1,
      startedAt: now,
      endsAt: now.add(const Duration(minutes: 10)),
      name: 'Sauce',
    );

    Future<void> pumpControls(CookTimer timer) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CookTimerControls(
            state: CookTimerState(
              now: now,
              isInitialized: true,
              timers: [timer],
            ),
            suggestedDuration: null,
            onStart: (_, __) async {},
            onPause: (value) async => paused = value,
            onResume: (value) async => resumed = value,
            onCancel: (_) async {},
          ),
        ),
      ));
      await tester.tap(find.byKey(const Key('manage-cook-timers')));
      await tester.pumpAndSettle();
    }

    await pumpControls(runningTimer);
    await tester.tap(find.byKey(const Key('pause-cook-timer-8')));
    await tester.pumpAndSettle();
    expect(paused, runningTimer);

    final pausedTimer = runningTimer.pauseAt(now);
    await pumpControls(pausedTimer);
    expect(find.text('Paused - Step 1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('resume-cook-timer-8')));
    await tester.pumpAndSettle();
    expect(resumed, pausedTimer);
  });
}
