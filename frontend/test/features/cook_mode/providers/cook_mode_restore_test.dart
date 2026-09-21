import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/providers/cook_mode_provider.dart';

void main() {
  test('restores a saved step within the recipe bounds', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    const args = CookModeArgs(recipeId: 7, stepCount: 3);
    final controller =
        container.read(cookModeControllerProvider(args).notifier);

    controller.restore(2);
    expect(
        container.read(cookModeControllerProvider(args)).currentStepIndex, 2);
    expect(
        container.read(cookModeControllerProvider(args)).isCompleted, isFalse);

    controller.restore(99);
    expect(
        container.read(cookModeControllerProvider(args)).currentStepIndex, 2);
    controller.restore(-5);
    expect(
        container.read(cookModeControllerProvider(args)).currentStepIndex, 0);
  });
}
