import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/models/cook_mode_state.dart';

void main() {
  test('reports navigation flags and progress for the current step', () {
    const first = CookModeState(totalSteps: 4);
    const middle = CookModeState(totalSteps: 4, currentStepIndex: 2);
    const last = CookModeState(totalSteps: 4, currentStepIndex: 3);

    expect(first.hasSteps, isTrue);
    expect(first.isFirstStep, isTrue);
    expect(first.canGoBack, isFalse);
    expect(first.progress, 0.25);

    expect(middle.isFirstStep, isFalse);
    expect(middle.isLastStep, isFalse);
    expect(middle.canGoBack, isTrue);
    expect(middle.progress, 0.75);

    expect(last.isLastStep, isTrue);
    expect(last.progress, 1);
  });

  test('handles empty and completed sessions', () {
    const empty = CookModeState(totalSteps: 0);
    const completed = CookModeState(
      totalSteps: 2,
      currentStepIndex: 1,
      isCompleted: true,
    );

    expect(empty.hasSteps, isFalse);
    expect(empty.isLastStep, isFalse);
    expect(empty.progress, 0);

    expect(completed.canGoBack, isTrue);
    expect(completed.progress, 1);
  });

  test('copyWith preserves values that are not replaced', () {
    const state = CookModeState(totalSteps: 3, currentStepIndex: 1);

    final updated = state.copyWith(isCompleted: true);

    expect(updated.totalSteps, 3);
    expect(updated.currentStepIndex, 1);
    expect(updated.isCompleted, isTrue);
  });
}
