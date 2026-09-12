import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cook_mode_state.dart';

class CookModeArgs {
  const CookModeArgs({required this.recipeId, required this.stepCount});

  final int recipeId;
  final int stepCount;

  @override
  bool operator ==(Object other) =>
      other is CookModeArgs &&
      other.recipeId == recipeId &&
      other.stepCount == stepCount;

  @override
  int get hashCode => Object.hash(recipeId, stepCount);
}

class CookModeController extends StateNotifier<CookModeState> {
  CookModeController({required int stepCount})
      : super(CookModeState(totalSteps: stepCount));

  void next() {
    if (!state.hasSteps || state.isCompleted) return;

    if (state.isLastStep) {
      state = state.copyWith(isCompleted: true);
      return;
    }

    state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
  }

  void back() {
    if (!state.canGoBack) return;

    if (state.isCompleted) {
      state = state.copyWith(isCompleted: false);
      return;
    }

    state = state.copyWith(currentStepIndex: state.currentStepIndex - 1);
  }

  void restart() {
    if (!state.hasSteps) return;
    state = state.copyWith(currentStepIndex: 0, isCompleted: false);
  }
}

final cookModeControllerProvider = StateNotifierProvider.autoDispose
    .family<CookModeController, CookModeState, CookModeArgs>((ref, args) {
  return CookModeController(stepCount: args.stepCount);
});
