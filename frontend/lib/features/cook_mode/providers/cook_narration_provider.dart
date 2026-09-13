import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cook_narration_state.dart';
import '../services/cook_narration_service.dart';

class _NarrationSegment {
  const _NarrationSegment({required this.text, required this.originalStart});

  final String text;
  final int originalStart;
}

class CookNarrationController extends StateNotifier<CookNarrationState> {
  CookNarrationController(this._service) : super(const CookNarrationState()) {
    _callbacks = CookNarrationCallbacks(
      onStart: _handleStart,
      onProgress: _handleProgress,
      onComplete: _handleComplete,
      onError: _handleError,
    );
  }

  static const int _fallbackMaxInputLength = 3000;
  static const int _minimumUsefulChunkLength = 64;

  final CookNarrationService _service;
  late final CookNarrationCallbacks _callbacks;

  bool _initialized = false;
  int _maxInputLength = _fallbackMaxInputLength;
  int _operation = 0;
  List<_NarrationSegment> _segments = const [];
  int _segmentIndex = 0;

  Future<void> speakStep(String text) => _speakFrom(text, 0);

  Future<void> pause() async {
    if (state.status != CookNarrationStatus.speaking &&
        state.status != CookNarrationStatus.preparing) {
      return;
    }

    final operation = ++_operation;
    final resumeOffset = state.activeStart ?? _currentSegmentStart;
    await _stopIgnoringFailure();
    if (operation != _operation || !mounted) return;

    state = state.copyWith(
      status: CookNarrationStatus.paused,
      resumeOffset: resumeOffset.clamp(0, state.stepText.length),
      clearActiveRange: true,
      clearError: true,
    );
  }

  Future<void> resume() async {
    if (!state.isPaused || state.stepText.isEmpty) return;
    await _speakFrom(state.stepText, state.resumeOffset);
  }

  Future<void> repeat() async {
    if (state.stepText.isEmpty) return;
    await _speakFrom(state.stepText, 0);
  }

  Future<void> stop() async {
    final operation = ++_operation;
    await _stopIgnoringFailure();
    if (operation != _operation || !mounted) return;

    state = state.copyWith(
      status: CookNarrationStatus.idle,
      resumeOffset: 0,
      clearActiveRange: true,
      clearError: true,
    );
  }

  Future<void> _speakFrom(String text, int requestedOffset) async {
    final operation = ++_operation;
    await _stopIgnoringFailure();
    if (operation != _operation || !mounted) return;

    final offset = requestedOffset.clamp(0, text.length);
    state = CookNarrationState(
      status: CookNarrationStatus.preparing,
      stepText: text,
      resumeOffset: offset,
    );

    try {
      if (!_initialized) {
        _maxInputLength = await _service.initialize(_callbacks);
        _initialized = true;
      }
      if (operation != _operation || !mounted) return;

      _segments = _splitIntoSegments(
        text,
        startOffset: offset,
        maxLength: _maxInputLength,
      );
      _segmentIndex = 0;

      if (_segments.isEmpty) {
        state = state.copyWith(
          status: CookNarrationStatus.completed,
          clearActiveRange: true,
        );
        return;
      }

      await _speakCurrentSegment(operation);
    } catch (error) {
      if (operation != _operation || !mounted) return;
      _setUnavailable(error);
    }
  }

  Future<void> _speakCurrentSegment(int operation) async {
    if (operation != _operation || !mounted) return;
    state = state.copyWith(
      status: CookNarrationStatus.speaking,
      resumeOffset: _currentSegmentStart,
      clearActiveRange: true,
      clearError: true,
    );
    await _service.speak(_segments[_segmentIndex].text);
  }

  void _handleStart() {
    if (!mounted || state.status != CookNarrationStatus.speaking) return;
    state = state.copyWith(status: CookNarrationStatus.speaking);
  }

  void _handleProgress(int start, int end, String word) {
    if (!mounted ||
        state.status != CookNarrationStatus.speaking ||
        _segments.isEmpty) {
      return;
    }

    final originalStart =
        (_currentSegmentStart + start).clamp(0, state.stepText.length);
    final originalEnd = (_currentSegmentStart + end)
        .clamp(originalStart, state.stepText.length);
    state = state.copyWith(
      activeStart: originalStart,
      activeEnd: originalEnd,
      resumeOffset: originalStart,
    );
  }

  void _handleComplete() {
    if (!mounted ||
        state.status != CookNarrationStatus.speaking ||
        _segments.isEmpty) {
      return;
    }

    if (_segmentIndex + 1 < _segments.length) {
      _segmentIndex++;
      unawaited(_speakCurrentSegment(_operation).catchError(_setUnavailable));
      return;
    }

    state = state.copyWith(
      status: CookNarrationStatus.completed,
      resumeOffset: state.stepText.length,
      clearActiveRange: true,
    );
  }

  void _handleError(String message) {
    if (!mounted) return;
    _setUnavailable(message);
  }

  void _setUnavailable(Object error) {
    if (!mounted) return;
    state = state.copyWith(
      status: CookNarrationStatus.unavailable,
      errorMessage: error.toString(),
      clearActiveRange: true,
    );
  }

  int get _currentSegmentStart => _segments.isEmpty
      ? state.resumeOffset
      : _segments[_segmentIndex].originalStart;

  Future<void> _stopIgnoringFailure() async {
    try {
      await _service.stop();
    } catch (_) {
      // A failed stop mustn't prevent navigation or manual Cook Mode.
    }
  }

  List<_NarrationSegment> _splitIntoSegments(
    String source, {
    required int startOffset,
    required int maxLength,
  }) {
    if (startOffset >= source.length) return const [];

    final safeMaxLength = maxLength < _minimumUsefulChunkLength
        ? _fallbackMaxInputLength
        : maxLength;
    final segments = <_NarrationSegment>[];
    var cursor = startOffset;

    while (cursor < source.length) {
      var end = (cursor + safeMaxLength).clamp(0, source.length);
      if (end < source.length) {
        end = _preferredBreak(source, cursor, end);
      }
      if (end <= cursor) {
        end = (cursor + safeMaxLength).clamp(0, source.length);
      }

      segments.add(
        _NarrationSegment(
          text: source.substring(cursor, end),
          originalStart: cursor,
        ),
      );
      cursor = end;
    }

    return segments;
  }

  int _preferredBreak(String source, int start, int limit) {
    final minimumBreak = start + ((limit - start) ~/ 2);

    for (var index = limit - 1; index >= minimumBreak; index--) {
      if ('.!?\n'.contains(source[index])) return index + 1;
    }
    for (var index = limit - 1; index >= minimumBreak; index--) {
      if (source[index].trim().isEmpty) return index + 1;
    }
    return limit;
  }

  @override
  void dispose() {
    _operation++;
    unawaited(_stopIgnoringFailure());
    super.dispose();
  }
}

final cookNarrationServiceProvider =
    Provider.autoDispose<CookNarrationService>((ref) {
  final service = FlutterTtsCookNarrationService();
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

final cookNarrationControllerProvider = StateNotifierProvider.autoDispose
    .family<CookNarrationController, CookNarrationState, int>((ref, recipeId) {
  return CookNarrationController(ref.watch(cookNarrationServiceProvider));
});
