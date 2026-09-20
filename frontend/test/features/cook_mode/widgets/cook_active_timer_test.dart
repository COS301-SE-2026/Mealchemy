import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/models/cook_timer.dart';
import 'package:mealchemy/features/cook_mode/widgets/cook_active_timer.dart';

void main() {
  testWidgets('shows a live clock for the active timer', (tester) async {
    final startedAt = DateTime.utc(2026, 9, 19, 12);
    final timer = CookTimer(
      notificationId: 1,
      recipeId: 7,
      recipeTitle: 'Pasta',
      stepIndex: 0,
      stepNumber: 1,
      startedAt: startedAt,
      endsAt: startedAt.add(const Duration(minutes: 20)),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: CookActiveTimer(
            timer: timer,
            now: startedAt.add(const Duration(minutes: 5)),
          ),
        ),
      ),
    ));

    final timerFinder = find.byKey(const Key('cook-active-timer-1'));
    expect(timerFinder, findsOneWidget);
    expect(tester.getSize(timerFinder), const Size.square(164));
    expect(find.text('15:00'), findsOneWidget);
    expect(find.text('Step 1'), findsOneWidget);
  });

  testWidgets('uses the smaller presentation in a timer group', (tester) async {
    final startedAt = DateTime.utc(2026, 9, 19, 12);
    final timer = CookTimer(
      notificationId: 2,
      recipeId: 7,
      recipeTitle: 'Pasta',
      stepIndex: 1,
      stepNumber: 2,
      startedAt: startedAt,
      endsAt: startedAt.add(const Duration(minutes: 10)),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: CookActiveTimer(
            timer: timer,
            now: startedAt,
            compact: true,
          ),
        ),
      ),
    ));

    final timerFinder = find.byKey(const Key('cook-active-timer-2'));
    expect(tester.getSize(timerFinder), const Size.square(124));
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('Step 2'), findsOneWidget);
  });
}
