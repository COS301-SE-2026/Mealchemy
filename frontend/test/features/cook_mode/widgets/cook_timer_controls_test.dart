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
}
