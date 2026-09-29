import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';

class CookNarrationCallbacks {
  const CookNarrationCallbacks({
    required this.onStart,
    required this.onProgress,
    required this.onComplete,
    required this.onError,
  });

  final void Function() onStart;
  final void Function(int start, int end, String word) onProgress;
  final void Function() onComplete;
  final void Function(String message) onError;
}

abstract class CookNarrationService {
  Future<int> initialize(CookNarrationCallbacks callbacks);

  Future<void> speak(String text);

  Future<void> stop();

  Future<void> dispose();
}

abstract interface class CookNarrationRateService {
  Future<void> setSpeechRate(double rate);
}

class FlutterTtsCookNarrationService
    implements CookNarrationService, CookNarrationRateService {
  FlutterTtsCookNarrationService({FlutterTts? flutterTts})
      : _flutterTts = flutterTts ?? FlutterTts();

  static const int _fallbackMaxInputLength = 3000;

  final FlutterTts _flutterTts;

  @override
  Future<int> initialize(CookNarrationCallbacks callbacks) async {
    _flutterTts.setStartHandler(callbacks.onStart);
    _flutterTts.setCompletionHandler(callbacks.onComplete);
    _flutterTts.setProgressHandler((text, start, end, word) {
      callbacks.onProgress(start, end, word);
    });
    _flutterTts.setErrorHandler((message) {
      callbacks.onError(message.toString());
    });

    if (Platform.isIOS) {
      await _flutterTts.setSharedInstance(true);
    }

    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);

    try {
      final maxLength = await _flutterTts.getMaxSpeechInputLength;
      return maxLength is int && maxLength > 0
          ? maxLength
          : _fallbackMaxInputLength;
    } catch (_) {
      return _fallbackMaxInputLength;
    }
  }

  @override
  Future<void> speak(String text) async {
    final result = await _flutterTts.speak(text);
    if (result != 1) {
      throw StateError('The device text-to-speech mechanism did not start.');
    }
  }

  @override
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  @override
  Future<void> dispose() => stop();
}
