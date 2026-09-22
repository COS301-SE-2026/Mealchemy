import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/services/cook_voice_service.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class _FakeSpeechToText extends Fake implements SpeechToText {
  SpeechResultListener? resultListener;
  SpeechSoundLevelChange? soundLevelListener;
  @override
  SpeechStatusListener? statusListener;
  SpeechListenOptions? options;
  int initializeCalls = 0;
  int cancelCalls = 0;
  bool available = true;

  @override
  Future<bool> initialize({
    SpeechErrorListener? onError,
    SpeechStatusListener? onStatus,
    dynamic debugLogging = false,
    Duration finalTimeout = const Duration(seconds: 2),
    List<SpeechConfigOption>? options,
  }) async {
    initializeCalls++;
    statusListener = onStatus;
    return available;
  }

  @override
  Future<void> listen({
    SpeechResultListener? onResult,
    Duration? listenFor,
    Duration? pauseFor,
    String? localeId,
    SpeechSoundLevelChange? onSoundLevelChange,
    dynamic cancelOnError = false,
    dynamic partialResults = true,
    dynamic onDevice = false,
    ListenMode listenMode = ListenMode.confirmation,
    dynamic sampleRate = 0,
    SpeechListenOptions? listenOptions,
  }) async {
    resultListener = onResult;
    soundLevelListener = onSoundLevelChange;
    options = listenOptions;
    statusListener?.call(SpeechToText.listeningStatus);
  }

  @override
  Future<void> cancel() async {
    cancelCalls++;
    statusListener?.call(SpeechToText.notListeningStatus);
  }
}

SpeechRecognitionResult _result(String words, ResultType type) =>
    SpeechRecognitionResult.init(
      [SpeechRecognitionWords(words, null, 0.9)],
      type,
    );

void main() {
  test('requires on-device recognition and ignores partial results', () async {
    final speech = _FakeSpeechToText();
    final service = SpeechToTextCookVoiceService(speech: speech);
    final results = <CookVoiceResult>[];
    final listening = <bool>[];
    final soundLevels = <double>[];
    final available = await service.initialize(CookVoiceCallbacks(
      onFinalResult: results.add,
      onListeningChanged: listening.add,
      onSoundLevel: soundLevels.add,
      onError: (_) {},
    ));
    expect(available, isTrue);

    await service.listen();
    expect(speech.options?.onDevice, isTrue);
    expect(speech.options?.partialResults, isFalse);
    expect(listening.last, isTrue);
    speech.soundLevelListener?.call(4.2);
    expect(soundLevels, [4.2]);
    speech.resultListener?.call(_result('next', ResultType.partial));
    expect(results, isEmpty);
    speech.resultListener?.call(_result('next', ResultType.finalResult));
    expect(results.single.words, 'next');
    expect(results.single.confidence, 0.9);
  });

  test('cancellation ignores a late final callback', () async {
    final speech = _FakeSpeechToText();
    final service = SpeechToTextCookVoiceService(speech: speech);
    final results = <CookVoiceResult>[];
    await service.initialize(CookVoiceCallbacks(
      onFinalResult: results.add,
      onListeningChanged: (_) {},
      onSoundLevel: (_) {},
      onError: (_) {},
    ));
    await service.listen();
    final oldListener = speech.resultListener;
    await service.stop();
    oldListener?.call(_result('next', ResultType.finalResult));

    expect(speech.cancelCalls, 1);
    expect(results, isEmpty);
  });

  test('unavailable recognition cannot start listening', () async {
    final speech = _FakeSpeechToText()..available = false;
    final service = SpeechToTextCookVoiceService(speech: speech);
    expect(
      await service.initialize(CookVoiceCallbacks(
        onFinalResult: (_) {},
        onListeningChanged: (_) {},
        onSoundLevel: (_) {},
        onError: (_) {},
      )),
      isFalse,
    );
    expect(() => service.listen(), throwsStateError);
    expect(speech.initializeCalls, 1);
  });
}
