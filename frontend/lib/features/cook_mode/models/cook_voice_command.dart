enum CookVoiceCommandType {
  next,
  back,
  repeat,
  startTimer,
  startSuggestedTimer,
}

class CookVoiceCommand {
  const CookVoiceCommand._(this.type, [this.duration]);

  static const next = CookVoiceCommand._(CookVoiceCommandType.next);
  static const back = CookVoiceCommand._(CookVoiceCommandType.back);
  static const repeat = CookVoiceCommand._(CookVoiceCommandType.repeat);
  static const startSuggestedTimer = CookVoiceCommand._(
    CookVoiceCommandType.startSuggestedTimer,
  );

  factory CookVoiceCommand.startTimer(Duration duration) {
    return CookVoiceCommand._(CookVoiceCommandType.startTimer, duration);
  }

  final CookVoiceCommandType type;
  final Duration? duration;

  @override
  bool operator ==(Object other) {
    return other is CookVoiceCommand &&
        other.type == type &&
        other.duration == duration;
  }

  @override
  int get hashCode => Object.hash(type, duration);
}

CookVoiceCommand? parseCookVoiceCommand(String words) {
  final phrase = words
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  return switch (phrase) {
    'next' || 'next step' || 'go to next step' => CookVoiceCommand.next,
    'back' ||
    'go back' ||
    'previous' ||
    'previous step' ||
    'go to previous step' =>
      CookVoiceCommand.back,
    'repeat' ||
    'repeat step' ||
    'repeat that' ||
    'say that again' ||
    'again' =>
      CookVoiceCommand.repeat,
    'start timer' ||
    'start the timer' ||
    'start suggested timer' ||
    'start the suggested timer' =>
      CookVoiceCommand.startSuggestedTimer,
    _ => null,
  };
}
