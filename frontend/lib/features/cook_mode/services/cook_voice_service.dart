import 'dart:io';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class CookVoiceResult {
  const CookVoiceResult({required this.words, this.confidence});

  final String words;
  final double? confidence;
}

class CookVoiceCallbacks {
  const CookVoiceCallbacks({
    required this.onFinalResult,
    required this.onListeningChanged,
    required this.onSoundLevel,
    required this.onError,
  });

  final void Function(CookVoiceResult result) onFinalResult;
  final void Function(bool listening) onListeningChanged;
  final void Function(double level) onSoundLevel;
  final void Function(String message) onError;
}

abstract class CookVoiceService {
  Future<bool> initialize(CookVoiceCallbacks callbacks);
  Future<void> listen();
  Future<void> stop();
  void detach();
  Future<void> dispose();
}

class SpeechToTextCookVoiceService implements CookVoiceService {
  SpeechToTextCookVoiceService({SpeechToText? speech})
      : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  CookVoiceCallbacks? _callbacks;
  Future<bool>? _initialization;
  bool _available = false;
  bool _started = false;
  int _generation = 0;

  @override
  Future<bool> initialize(CookVoiceCallbacks callbacks) {
    _callbacks = callbacks;
    return _initialization ??= _initialize();
  }

  Future<bool> _initialize() async {
    try {
      _available = await _speech.initialize(
        onStatus: (status) {
          if (status == SpeechToText.listeningStatus) {
            _callbacks?.onListeningChanged(true);
          } else if (status == SpeechToText.doneStatus ||
              status == SpeechToText.notListeningStatus) {
            _callbacks?.onListeningChanged(false);
          }
        },
        onError: (error) {
          _generation++;
          _started = false;
          _callbacks?.onListeningChanged(false);
          _callbacks?.onError(error.errorMsg);
        },
        options: Platform.isAndroid ? [SpeechToText.androidNoBluetooth] : null,
      );
      return _available;
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }

  @override
  Future<void> listen() async {
    if (!_available) throw StateError('Speech recognition is unavailable.');
    final generation = ++_generation;
    _started = true;
    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          if (generation != _generation || !result.finalResult) return;
          _callbacks?.onFinalResult(CookVoiceResult(
            words: result.recognizedWords,
            confidence: result.hasConfidenceRating ? result.confidence : null,
          ));
        },
        onSoundLevelChange: (level) {
          if (generation != _generation) return;
          _callbacks?.onSoundLevel(level);
        },
        listenOptions: SpeechListenOptions(
          onDevice: true,
          partialResults: false,
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 3),
        ),
      );
    } catch (_) {
      _started = false;
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    _generation++;
    final started = _started;
    _started = false;
    try {
      if (started) await _speech.cancel();
    } finally {
      _callbacks?.onListeningChanged(false);
    }
  }

  @override
  void detach() {
    _generation++;
    _callbacks = null;
  }

  @override
  Future<void> dispose() async {
    await stop();
    detach();
  }
}
