import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/models/cook_narration_state.dart';
import 'package:mealchemy/features/cook_mode/models/cook_timer.dart';
import 'package:mealchemy/features/cook_mode/widgets/cook_step_stage.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';

const _step = RecipeStep(stepNr: 1, content: 'Boil the pasta.');

Widget _host({
  CookNarrationState narration = const CookNarrationState(),
  List<CookTimer> timers = const [],
  DateTime? now,
}) {
  return MaterialApp(
    home: Scaffold(
      body: CookStepStage(
        step: _step,
        narration: narration,
        activeTimers: timers,
        now: now ?? DateTime.utc(2026, 9, 19, 12),
      ),
    ),
  );
}

void main() {
  testWidgets('keeps the plain instruction central in manual mode',
      (tester) async {
    await tester.pumpWidget(_host());

    expect(find.text('Boil the pasta.'), findsOneWidget);
    expect(find.byKey(const Key('cook-active-timer-group')), findsNothing);
  });

  testWidgets('preserves narration highlighting', (tester) async {
    await tester.pumpWidget(_host(
      narration: const CookNarrationState(
        status: CookNarrationStatus.speaking,
        stepText: 'Boil the pasta.',
        activeStart: 0,
        activeEnd: 4,
      ),
    ));

    final text = tester.widget<Text>(find.byKey(const Key('cook-step-text')));
    final rootSpan = text.textSpan! as TextSpan;
    final highlighted = rootSpan.children![1] as TextSpan;
    expect(highlighted.text, 'Boil');
    expect(highlighted.style?.backgroundColor, isNotNull);
  });

  testWidgets('places an active timer in the central stage', (tester) async {
    final now = DateTime.utc(2026, 9, 19, 12);
    final timer = CookTimer(
      notificationId: 1,
      recipeId: 7,
      recipeTitle: 'Pasta',
      stepIndex: 0,
      stepNumber: 1,
      startedAt: now,
      endsAt: now.add(const Duration(minutes: 20)),
    );

    await tester.pumpWidget(_host(timers: [timer], now: now));

    expect(find.text('Boil the pasta.'), findsOneWidget);
    expect(find.byKey(const Key('cook-active-timer-group')), findsOneWidget);
    expect(find.byKey(const Key('cook-active-timer-1')), findsOneWidget);
    expect(find.text('20:00'), findsOneWidget);
  });

  testWidgets('shows two compact timers together', (tester) async {
    final now = DateTime.utc(2026, 9, 19, 12);
    final timers = [
      CookTimer(
        notificationId: 1,
        recipeId: 7,
        recipeTitle: 'Pasta',
        stepIndex: 0,
        stepNumber: 1,
        startedAt: now,
        endsAt: now.add(const Duration(minutes: 20)),
      ),
      CookTimer(
        notificationId: 2,
        recipeId: 7,
        recipeTitle: 'Pasta',
        stepIndex: 1,
        stepNumber: 2,
        startedAt: now,
        endsAt: now.add(const Duration(minutes: 8)),
      ),
    ];

    await tester.pumpWidget(_host(timers: timers, now: now));

    final first = find.byKey(const Key('cook-active-timer-1'));
    final second = find.byKey(const Key('cook-active-timer-2'));
    expect(first, findsOneWidget);
    expect(second, findsOneWidget);
    expect(tester.getSize(first), const Size.square(124));
    expect(tester.getSize(second), const Size.square(124));
    expect(find.text('20:00'), findsOneWidget);
    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('Step 1'), findsOneWidget);
    expect(find.text('Step 2'), findsOneWidget);
  });
}
