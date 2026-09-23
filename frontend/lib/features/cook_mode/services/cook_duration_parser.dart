import '../models/cook_voice_command.dart';

const _numberPattern =
    r'(?:\d+|a|an|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty|thirty|forty|fifty|sixty|seventy|eighty|ninety)(?:[ -](?:one|two|three|four|five|six|seven|eight|nine))?';
const _unitPattern = r'(?:seconds?|secs?|minutes?|mins?|hours?|hrs?)';

final RegExp _durationComponent = RegExp(
  '($_numberPattern)\\s*($_unitPattern)',
  caseSensitive: false,
);
final RegExp _passiveDuration = RegExp(
  '\\bfor\\s+($_numberPattern\\s*$_unitPattern'
  '(?:\\s*(?:and|,)\\s*$_numberPattern\\s*$_unitPattern)?)',
  caseSensitive: false,
);

Duration? parseCookDuration(String source) {
  final normalized = source
      .toLowerCase()
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (normalized.isEmpty) return null;

  final matches = _durationComponent.allMatches(normalized).toList();
  if (matches.isEmpty) return null;

  var residue = normalized;
  for (final match in matches.reversed) {
    residue = residue.replaceRange(match.start, match.end, ' ');
  }
  residue = residue
      .replaceAll(RegExp(r'\b(?:and|for)\b'), ' ')
      .replaceAll(',', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (residue.isNotEmpty) return null;

  var seconds = 0;
  final seenUnits = <String>{};
  for (final match in matches) {
    final amount = _parseNumber(match.group(1)!);
    final unit = match.group(2)!.toLowerCase();
    final canonicalUnit = unit.startsWith('h')
        ? 'hours'
        : unit.startsWith('m')
            ? 'minutes'
            : 'seconds';
    if (amount == null || amount <= 0 || !seenUnits.add(canonicalUnit)) {
      return null;
    }
    seconds += switch (canonicalUnit) {
      'hours' => amount * 3600,
      'minutes' => amount * 60,
      _ => amount,
    };
  }

  if (seconds <= 0 || seconds > const Duration(hours: 24).inSeconds) {
    return null;
  }
  return Duration(seconds: seconds);
}

Duration? detectCookStepDuration(String stepText) {
  final matches = _passiveDuration.allMatches(stepText).toList();
  if (matches.length != 1) return null;
  return parseCookDuration(matches.single.group(1)!);
}

CookVoiceCommand? parseCookVoiceIntent(String words) {
  final fixedCommand = parseCookVoiceCommand(words);
  if (fixedCommand != null) return fixedCommand;

  final normalized = words
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  final patterns = [
    RegExp(r'^(?:set|start) (?:a )?timer for (.+)$'),
    RegExp(r'^(?:set|start) (?:a )?(.+) timer$'),
  ];

  for (final pattern in patterns) {
    final match = pattern.firstMatch(normalized);
    if (match == null) continue;
    final duration = parseCookDuration(match.group(1)!);
    if (duration != null) return CookVoiceCommand.startTimer(duration);
  }
  return null;
}

int? _parseNumber(String source) {
  final numeric = int.tryParse(source);
  if (numeric != null) return numeric;

  const values = <String, int>{
    'a': 1,
    'an': 1,
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9,
    'ten': 10,
    'eleven': 11,
    'twelve': 12,
    'thirteen': 13,
    'fourteen': 14,
    'fifteen': 15,
    'sixteen': 16,
    'seventeen': 17,
    'eighteen': 18,
    'nineteen': 19,
    'twenty': 20,
    'thirty': 30,
    'forty': 40,
    'fifty': 50,
    'sixty': 60,
    'seventy': 70,
    'eighty': 80,
    'ninety': 90,
  };

  var total = 0;
  for (final word in source.replaceAll('-', ' ').split(' ')) {
    final value = values[word];
    if (value == null) return null;
    total += value;
  }
  return total;
}
