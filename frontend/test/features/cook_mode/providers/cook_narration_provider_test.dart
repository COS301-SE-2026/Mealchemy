import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/models/cook_narration_state.dart';
import 'package:mealchemy/features/cook_mode/providers/cook_narration_provider.dart';
import 'package:mealchemy/features/cook_mode/services/cook_narration_service.dart';

class _FakeNarrationService implements CookNarrationService {
  _FakeNarrationService({this.maxInputLength = 3000});

  final int maxInputLength;
  CookNarrationCallbacks? callbacks;
  final List<String> spoken = [];
  int stopCalls = 0;
  Object? initializeError;
  Object? stopError;

  @override
  Future<int> initialize(CookNarrationCallbacks callbacks) async {
    if (initializeError != null) throw initializeError!;
    this.callbacks = callbacks;
    return maxInputLength;
  }

  @override
  Future<void> speak(String text) async {
    spoken.add(text);
    callbacks?.onStart();
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    if (stopError != null) throw stopError!;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  test('maps progress to the original step text', () async {
    final service = _FakeNarrationService();
    final controller = CookNarrationController(service);

    await controller.speakStep('Chop onions finely.');
    service.callbacks?.onProgress(5, 11, 'onions');

    expect(controller.state.activeStart, 5);
    expect(controller.state.activeEnd, 11);
    expect(controller.state.resumeOffset, 5);
  });

  test('pause and resume speak from the current original offset', () async {
    final service = _FakeNarrationService();
    final controller = CookNarrationController(service);

    await controller.speakStep('Chop onions finely.');
    service.callbacks?.onProgress(5, 11, 'onions');
    await controller.pause();

    expect(controller.state.status, CookNarrationStatus.paused);
    expect(controller.state.activeStart, isNull);

    await controller.resume();
    expect(service.spoken.last, 'onions finely.');

    service.callbacks?.onProgress(0, 6, 'onions');
    expect(controller.state.activeStart, 5);
    expect(controller.state.activeEnd, 11);
  });

  test('continues chunks while preserving their original offsets', () async {
    final service = _FakeNarrationService(maxInputLength: 64);
    final controller = CookNarrationController(service);
    final text = '${'First sentence. ' * 5}Last sentence.';

    await controller.speakStep(text);
    expect(service.spoken.length, 1);

    final firstLength = service.spoken.first.length;
    service.callbacks?.onComplete();
    await Future<void>.delayed(Duration.zero);

    expect(service.spoken.length, 2);
    service.callbacks?.onProgress(0, 4, 'next');
    expect(controller.state.activeStart, firstLength);
  });

  test('repeat starts the full step again', () async {
    final service = _FakeNarrationService();
    final controller = CookNarrationController(service);

    await controller.speakStep('Stir gently.');
    service.callbacks?.onProgress(5, 11, 'gently');
    await controller.repeat();

    expect(service.spoken.last, 'Stir gently.');
    expect(controller.state.resumeOffset, 0);
  });

  test('empty text completes without asking the engine to speak', () async {
    final service = _FakeNarrationService();
    final controller = CookNarrationController(service);

    await controller.speakStep('');

    expect(controller.state.status, CookNarrationStatus.completed);
    expect(service.spoken, isEmpty);
  });

  test('clamps out-of-range progress callbacks to the step', () async {
    final service = _FakeNarrationService();
    final controller = CookNarrationController(service);

    await controller.speakStep('Stir.');
    service.callbacks?.onProgress(-10, 100, 'Stir');

    expect(controller.state.activeStart, 0);
    expect(controller.state.activeEnd, 5);
  });

  test('a failed stop does not prevent a new step from speaking', () async {
    final service = _FakeNarrationService()
      ..stopError = StateError('stop failed');
    final controller = CookNarrationController(service);

    await controller.speakStep('Continue cooking.');

    expect(service.spoken, ['Continue cooking.']);
    expect(controller.state.status, CookNarrationStatus.speaking);
  });

  test('completion clears the active range', () async {
    final service = _FakeNarrationService();
    final controller = CookNarrationController(service);

    await controller.speakStep('Serve.');
    service.callbacks?.onProgress(0, 5, 'Serve');
    service.callbacks?.onComplete();

    expect(controller.state.status, CookNarrationStatus.completed);
    expect(controller.state.activeStart, isNull);
    expect(controller.state.activeEnd, isNull);
    expect(controller.state.resumeOffset, 6);
  });

  test('initialization failure leaves manual cooking available', () async {
    final service = _FakeNarrationService()
      ..initializeError = StateError('No TTS engine');
    final controller = CookNarrationController(service);

    await controller.speakStep('Keep cooking.');

    expect(controller.state.status, CookNarrationStatus.unavailable);
    expect(controller.state.errorMessage, contains('No TTS engine'));
  });
}
