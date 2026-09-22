import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/cook_mode/services/screen_awake_service.dart';

void main() {
  test('delegates enable and disable to the configured platform actions',
      () async {
    var enableCalls = 0;
    var disableCalls = 0;
    final service = WakelockScreenAwakeService(
      enableAction: () async => enableCalls++,
      disableAction: () async => disableCalls++,
    );

    await service.enable();
    await service.disable();

    expect(enableCalls, 1);
    expect(disableCalls, 1);
  });

  test('propagates platform failures to the caller', () async {
    final service = WakelockScreenAwakeService(
      enableAction: () => Future<void>.error(StateError('unavailable')),
      disableAction: () async {},
    );

    await expectLater(service.enable(), throwsStateError);
  });
}
