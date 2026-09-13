import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/services/cook_narration_service.dart';

class _FakeFlutterTts implements FlutterTts {
  final Map<Symbol, Function> handlers = {};
  final List<String> spoken = [];
  final List<double> speechRates = [];
  final List<double> pitches = [];
  final List<double> volumes = [];
  int stopCalls = 0;
  int maxInputLength = 2048;
  int speakResult = 1;
  bool failMaxInputLength = false;

  @override
  Future<int?> get getMaxSpeechInputLength async {
    if (failMaxInputLength) throw StateError('unsupported');
    return maxInputLength;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final member = invocation.memberName;
    if (member == #setStartHandler ||
        member == #setCompletionHandler ||
        member == #setProgressHandler ||
        member == #setErrorHandler) {
      handlers[member] = invocation.positionalArguments.first as Function;
      return null;
    }
    if (member == #setSpeechRate) {
      speechRates.add(invocation.positionalArguments.first as double);
      return Future<dynamic>.value(1);
    }
    if (member == #setPitch) {
      pitches.add(invocation.positionalArguments.first as double);
      return Future<dynamic>.value(1);
    }
    if (member == #setVolume) {
      volumes.add(invocation.positionalArguments.first as double);
      return Future<dynamic>.value(1);
    }
    if (member == #speak) {
      spoken.add(invocation.positionalArguments.first as String);
      return Future<dynamic>.value(speakResult);
    }
    if (member == #stop) {
      stopCalls++;
      return Future<dynamic>.value(1);
    }
    if (member == #setSharedInstance) {
      return Future<dynamic>.value(1);
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  test('configures TTS and forwards native callbacks', () async {
    final flutterTts = _FakeFlutterTts();
    final service = FlutterTtsCookNarrationService(flutterTts: flutterTts);
    var starts = 0;
    var completions = 0;
    var progressStart = -1;
    var progressEnd = -1;
    var progressWord = '';
    var error = '';

    final maxLength = await service.initialize(
      CookNarrationCallbacks(
        onStart: () => starts++,
        onProgress: (start, end, word) {
          progressStart = start;
          progressEnd = end;
          progressWord = word;
        },
        onComplete: () => completions++,
        onError: (message) => error = message,
      ),
    );

    expect(maxLength, 2048);
    expect(flutterTts.speechRates, [0.5]);
    expect(flutterTts.pitches, [1.0]);
    expect(flutterTts.volumes, [1.0]);

    Function.apply(flutterTts.handlers[#setStartHandler]!, const []);
    Function.apply(
      flutterTts.handlers[#setProgressHandler]!,
      const ['ignored text', 2, 6, 'step'],
    );
    Function.apply(flutterTts.handlers[#setCompletionHandler]!, const []);
    Function.apply(
      flutterTts.handlers[#setErrorHandler]!,
      const ['engine error'],
    );

    expect(starts, 1);
    expect(completions, 1);
    expect(progressStart, 2);
    expect(progressEnd, 6);
    expect(progressWord, 'step');
    expect(error, 'engine error');
  });

  test('uses a safe input-length fallback when the query is unsupported',
      () async {
    final flutterTts = _FakeFlutterTts()..failMaxInputLength = true;
    final service = FlutterTtsCookNarrationService(flutterTts: flutterTts);

    final maxLength = await service.initialize(
      CookNarrationCallbacks(
        onStart: () {},
        onProgress: (start, end, word) {},
        onComplete: () {},
        onError: (message) {},
      ),
    );

    expect(maxLength, 3000);
  });

  test('speaks, stops, disposes, and reports a rejected utterance', () async {
    final flutterTts = _FakeFlutterTts();
    final service = FlutterTtsCookNarrationService(flutterTts: flutterTts);

    await service.speak('Read this step.');
    await service.stop();
    await service.dispose();

    expect(flutterTts.spoken, ['Read this step.']);
    expect(flutterTts.stopCalls, 2);

    flutterTts.speakResult = 0;
    await expectLater(service.speak('Rejected'), throwsStateError);
  });
}
