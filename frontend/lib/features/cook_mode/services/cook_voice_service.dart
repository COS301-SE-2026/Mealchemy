import 'dart:async';
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
  Timer? _finalizeTimer;
  CookVoiceResult? _pendingResult;
  bool _resultEmitted = false;

  static const _finalizeDebounce = Duration(milliseconds: 600);

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
          // ignore: avoid_print
          print('STT onError: ${error.errorMsg} permanent=${error.permanent}');
          _cancelFinalization();
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
    _cancelFinalization();
    final generation = ++_generation;
    _started = true;
    _resultEmitted = false;

    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          // ignore: avoid_print
          print('STT onResult: "${result.recognizedWords}" '
              'final=${result.finalResult} confidence=${result.confidence}');
          if (generation != _generation || _resultEmitted) return;
          final words = result.recognizedWords.trim();
          if (words.isEmpty) return;

          final cookResult = CookVoiceResult(
            words: words,
            confidence: result.hasConfidenceRating ? result.confidence : null,
          );
          _pendingResult = cookResult;

          if (result.finalResult) {
            _emitFinal(generation, cookResult);
            return;
          }

          _finalizeTimer?.cancel();
          _finalizeTimer = Timer(_finalizeDebounce, () {
            final pendingResult = _pendingResult;
            if (pendingResult != null) {
              _emitFinal(generation, pendingResult);
            }
          });
        },
        onSoundLevelChange: (level) {
          if (generation != _generation) return;
          _callbacks?.onSoundLevel(level);
        },
        listenOptions: SpeechListenOptions(
          onDevice: false,
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 3),
        ),
      );
    } catch (_) {
      _cancelFinalization();
      _started = false;
      rethrow;
    }
  }

  void _emitFinal(int generation, CookVoiceResult result) {
    if (generation != _generation || _resultEmitted) return;
    _finalizeTimer?.cancel();
    _finalizeTimer = null;
    _pendingResult = null;
    _resultEmitted = true;
    // ignore: avoid_print
    print('STT emitFinal: "${result.words}" confidence=${result.confidence}');
    _callbacks?.onFinalResult(result);
  }

  void _cancelFinalization() {
    _finalizeTimer?.cancel();
    _finalizeTimer = null;
    _pendingResult = null;
  }

  @override
  Future<void> stop() async {
    _cancelFinalization();
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
    _cancelFinalization();
    _generation++;
    _callbacks = null;
  }

  @override
  Future<void> dispose() async {
    await stop();
    detach();
  }
}
