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

    expect(find.byKey(const Key('cook-active-timer')), findsOneWidget);
    expect(find.text('15:00'), findsOneWidget);
    expect(find.text('Cooking timer'), findsOneWidget);
  });
}
