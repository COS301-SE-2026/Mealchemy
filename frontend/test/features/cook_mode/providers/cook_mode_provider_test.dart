import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/providers/cook_mode_provider.dart';

void main() {
  test('moves through steps and completes at the final step', () {
    final controller = CookModeController(stepCount: 2);

    expect(controller.state.currentStepIndex, 0);
    expect(controller.state.progress, 0.5);

    controller.next();
    expect(controller.state.currentStepIndex, 1);
    expect(controller.state.isCompleted, isFalse);

    controller.next();
    expect(controller.state.isCompleted, isTrue);
    expect(controller.state.progress, 1);
  });

  test('back stays in bounds and returns from completion', () {
    final controller = CookModeController(stepCount: 2);

    controller.back();
    expect(controller.state.currentStepIndex, 0);

    controller.next();
    controller.next();
    controller.back();
    expect(controller.state.currentStepIndex, 1);
    expect(controller.state.isCompleted, isFalse);

    controller.back();
    expect(controller.state.currentStepIndex, 0);
  });

  test('restart returns to the first step', () {
    final controller = CookModeController(stepCount: 1);

    controller.next();
    controller.restart();

    expect(controller.state.currentStepIndex, 0);
    expect(controller.state.isCompleted, isFalse);
  });
}
