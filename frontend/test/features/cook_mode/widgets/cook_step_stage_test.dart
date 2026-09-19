import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/models/cook_narration_state.dart';
import 'package:mealchemy/features/cook_mode/models/cook_timer.dart';
import 'package:mealchemy/features/cook_mode/widgets/cook_step_stage.dart';
import 'package:mealchemy/features/recipe/models/recipe_step.dart';

const _step = RecipeStep(stepNr: 1, content: 'Boil the pasta.');

Widget _host({
  CookNarrationState narration = const CookNarrationState(),
  CookTimer? timer,
  DateTime? now,
}) {
  return MaterialApp(
    home: Scaffold(
      body: CookStepStage(
        step: _step,
        narration: narration,
        activeTimer: timer,
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
    expect(find.byKey(const Key('cook-active-timer')), findsNothing);
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

    await tester.pumpWidget(_host(timer: timer, now: now));

    expect(find.text('Boil the pasta.'), findsOneWidget);
    expect(find.byKey(const Key('cook-active-timer')), findsOneWidget);
    expect(find.text('20:00'), findsOneWidget);
  });
}
