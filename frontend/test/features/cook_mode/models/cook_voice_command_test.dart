import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/models/cook_voice_command.dart';

void main() {
  final cases = <String, CookVoiceCommand?>{
    'next': CookVoiceCommand.next,
    'Next step!': CookVoiceCommand.next,
    'go to next step': CookVoiceCommand.next,
    'back': CookVoiceCommand.back,
    'Go back.': CookVoiceCommand.back,
    'previous step': CookVoiceCommand.back,
    'repeat': CookVoiceCommand.repeat,
    'say that again': CookVoiceCommand.repeat,
    '  REPEAT   THAT  ': CookVoiceCommand.repeat,
    'start the timer': CookVoiceCommand.startSuggestedTimer,
    'start suggested timer': CookVoiceCommand.startSuggestedTimer,
    'not next': null,
    'next week': null,
    'add salt': null,
    '': null,
  };

  for (final entry in cases.entries) {
    test('parses "${entry.key}"', () {
      expect(parseCookVoiceCommand(entry.key), entry.value);
    });
  }
}
