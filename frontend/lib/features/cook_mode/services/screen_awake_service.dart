import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

abstract class ScreenAwakeService {
  Future<void> enable();

  Future<void> disable();
}

class WakelockScreenAwakeService implements ScreenAwakeService {
  WakelockScreenAwakeService({
    Future<void> Function()? enableAction,
    Future<void> Function()? disableAction,
  })  : _enableAction = enableAction ?? WakelockPlus.enable,
        _disableAction = disableAction ?? WakelockPlus.disable;

  final Future<void> Function() _enableAction;
  final Future<void> Function() _disableAction;

  @override
  Future<void> enable() => _enableAction();

  @override
  Future<void> disable() => _disableAction();
}

final screenAwakeServiceProvider = Provider<ScreenAwakeService>((ref) {
  return WakelockScreenAwakeService();
});
