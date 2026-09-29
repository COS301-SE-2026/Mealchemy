import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/models/cook_narration_state.dart';

void main() {
  test('reports status helpers', () {
    const speaking = CookNarrationState(
      status: CookNarrationStatus.speaking,
    );
    const paused = CookNarrationState(status: CookNarrationStatus.paused);
    const unavailable = CookNarrationState(
      status: CookNarrationStatus.unavailable,
    );

    expect(speaking.isSpeaking, isTrue);
    expect(speaking.isPaused, isFalse);
    expect(paused.isPaused, isTrue);
    expect(unavailable.isUnavailable, isTrue);
  });

  test('copyWith can replace and clear narration details', () {
    const state = CookNarrationState(
      status: CookNarrationStatus.speaking,
      stepText: 'Stir the sauce.',
      activeStart: 0,
      activeEnd: 4,
      resumeOffset: 0,
      errorMessage: 'old error',
    );

    final updated = state.copyWith(
      status: CookNarrationStatus.paused,
      resumeOffset: 4,
      clearActiveRange: true,
      clearError: true,
    );

    expect(updated.status, CookNarrationStatus.paused);
    expect(updated.stepText, 'Stir the sauce.');
    expect(updated.resumeOffset, 4);
    expect(updated.activeStart, isNull);
    expect(updated.activeEnd, isNull);
    expect(updated.errorMessage, isNull);
  });
}
