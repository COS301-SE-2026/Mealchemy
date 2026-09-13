enum CookNarrationStatus {
  idle,
  preparing,
  speaking,
  paused,
  completed,
  unavailable,
}

class CookNarrationState {
  const CookNarrationState({
    this.status = CookNarrationStatus.idle,
    this.stepText = '',
    this.activeStart,
    this.activeEnd,
    this.resumeOffset = 0,
    this.errorMessage,
  });

  final CookNarrationStatus status;
  final String stepText;
  final int? activeStart;
  final int? activeEnd;
  final int resumeOffset;
  final String? errorMessage;

  bool get isSpeaking => status == CookNarrationStatus.speaking;
  bool get isPaused => status == CookNarrationStatus.paused;
  bool get isUnavailable => status == CookNarrationStatus.unavailable;

  CookNarrationState copyWith({
    CookNarrationStatus? status,
    String? stepText,
    int? activeStart,
    int? activeEnd,
    int? resumeOffset,
    String? errorMessage,
    bool clearActiveRange = false,
    bool clearError = false,
  }) {
    return CookNarrationState(
      status: status ?? this.status,
      stepText: stepText ?? this.stepText,
      activeStart: clearActiveRange ? null : activeStart ?? this.activeStart,
      activeEnd: clearActiveRange ? null : activeEnd ?? this.activeEnd,
      resumeOffset: resumeOffset ?? this.resumeOffset,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
