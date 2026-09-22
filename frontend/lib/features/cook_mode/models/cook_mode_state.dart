class CookModeState {
  const CookModeState({
    required this.totalSteps,
    this.currentStepIndex = 0,
    this.isCompleted = false,
  }) : assert(totalSteps >= 0);

  final int totalSteps;
  final int currentStepIndex;
  final bool isCompleted;

  bool get hasSteps => totalSteps > 0;
  bool get isFirstStep => currentStepIndex == 0;
  bool get isLastStep => hasSteps && currentStepIndex == totalSteps - 1;
  bool get canGoBack => hasSteps && (currentStepIndex > 0 || isCompleted);

  double get progress {
    if (!hasSteps) return 0;
    if (isCompleted) return 1;
    return (currentStepIndex + 1) / totalSteps;
  }

  CookModeState copyWith({
    int? currentStepIndex,
    bool? isCompleted,
  }) {
    return CookModeState(
      totalSteps: totalSteps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
