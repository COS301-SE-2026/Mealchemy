import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/models/cook_voice_command.dart';
import 'package:mealchemy/features/cook_mode/services/cook_duration_parser.dart';

void main() {
  group('parseCookDuration', () {
    final validCases = <String, Duration>{
      '20 minutes': const Duration(minutes: 20),
      'ten minutes': const Duration(minutes: 10),
      'one hour and twenty minutes': const Duration(hours: 1, minutes: 20),
      '45 seconds': const Duration(seconds: 45),
      'an hour': const Duration(hours: 1),
    };

    for (final entry in validCases.entries) {
      test('parses ${entry.key}', () {
        expect(parseCookDuration(entry.key), entry.value);
      });
    }

    test('rejects ranges, repeated units, and excessive durations', () {
      expect(parseCookDuration('10 to 15 minutes'), isNull);
      expect(parseCookDuration('10 minutes and 5 minutes'), isNull);
      expect(parseCookDuration('25 hours'), isNull);
      expect(parseCookDuration('a little while'), isNull);
    });
  });

  group('detectCookStepDuration', () {
    test('detects one duration anchored by for', () {
      expect(
        detectCookStepDuration('Lower the heat and simmer for 20 minutes.'),
        const Duration(minutes: 20),
      );
    });

    test('does not guess when a step contains multiple durations', () {
      expect(
        detectCookStepDuration(
          'Rest for 10 minutes, then bake for 20 minutes.',
        ),
        isNull,
      );
    });

    test('does not treat ingredient quantities as timers', () {
      expect(detectCookStepDuration('Add 2 cups of stock and stir.'), isNull);
    });
  });

  group('parseCookVoiceIntent', () {
    test('preserves fixed navigation commands', () {
      expect(parseCookVoiceIntent('next step'), CookVoiceCommand.next);
    });

    test('parses data-bearing timer commands', () {
      expect(
        parseCookVoiceIntent('set a timer for ten minutes'),
        CookVoiceCommand.startTimer(const Duration(minutes: 10)),
      );
      expect(
        parseCookVoiceIntent('start a 45 second timer'),
        CookVoiceCommand.startTimer(const Duration(seconds: 45)),
      );
    });

    test('rejects open-ended or incomplete timer requests', () {
      expect(parseCookVoiceIntent('set a timer'), isNull);
      expect(parseCookVoiceIntent('cook it longer'), isNull);
    });
  });
}
