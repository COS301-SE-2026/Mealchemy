enum CookVoiceCommand { next, back, repeat }

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
    _ => null,
  };
}
