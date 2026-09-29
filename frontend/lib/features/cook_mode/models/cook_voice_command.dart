enum CookVoiceCommandType {
  next,
  back,
  repeat,
  startTimer,
  startSuggestedTimer,
  pauseTimer,
  resumeTimer,
}

class CookVoiceCommand {
  const CookVoiceCommand._(
    this.type, {
    this.duration,
    this.timerName,
  });

  static const next = CookVoiceCommand._(CookVoiceCommandType.next);
  static const back = CookVoiceCommand._(CookVoiceCommandType.back);
  static const repeat = CookVoiceCommand._(CookVoiceCommandType.repeat);
  static const startSuggestedTimer = CookVoiceCommand._(
    CookVoiceCommandType.startSuggestedTimer,
  );
  static const pauseTimer = CookVoiceCommand._(
    CookVoiceCommandType.pauseTimer,
  );
  static const resumeTimer = CookVoiceCommand._(
    CookVoiceCommandType.resumeTimer,
  );

  factory CookVoiceCommand.startTimer(Duration duration) {
    return CookVoiceCommand._(
      CookVoiceCommandType.startTimer,
      duration: duration,
    );
  }

  factory CookVoiceCommand.pauseNamedTimer(String timerName) {
    return CookVoiceCommand._(
      CookVoiceCommandType.pauseTimer,
      timerName: timerName,
    );
  }

  factory CookVoiceCommand.resumeNamedTimer(String timerName) {
    return CookVoiceCommand._(
      CookVoiceCommandType.resumeTimer,
      timerName: timerName,
    );
  }

  final CookVoiceCommandType type;
  final Duration? duration;
  final String? timerName;

  @override
  bool operator ==(Object other) {
    return other is CookVoiceCommand &&
        other.type == type &&
        other.duration == duration &&
        other.timerName == timerName;
  }

  @override
  int get hashCode => Object.hash(type, duration, timerName);
}

CookVoiceCommand? parseCookVoiceCommand(String words) {
  final phrase = words
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  return switch (phrase) {
    'next' ||
    'next step' ||
    'go next' ||
    'go to next step' ||
    'next please' ||
    'please go to the next step' =>
      CookVoiceCommand.next,
    'back' ||
    'go back' ||
    'previous' ||
    'previous step' ||
    'go to previous step' ||
    'back please' ||
    'please go back' =>
      CookVoiceCommand.back,
    'repeat' ||
    'repeat step' ||
    'repeat that' ||
    'say that again' ||
    'repeat please' ||
    'please repeat' ||
    'again' =>
      CookVoiceCommand.repeat,
    'start timer' ||
    'start the timer' ||
    'start suggested timer' ||
    'start the suggested timer' =>
      CookVoiceCommand.startSuggestedTimer,
    'pause timer' || 'pause the timer' => CookVoiceCommand.pauseTimer,
    'resume timer' ||
    'resume the timer' ||
    'continue timer' ||
    'continue the timer' =>
      CookVoiceCommand.resumeTimer,
    _ => null,
  };
}
