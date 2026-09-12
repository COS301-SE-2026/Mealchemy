import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

abstract class ScreenAwakeService {
  Future<void> enable();

  Future<void> disable();
}

class WakelockScreenAwakeService implements ScreenAwakeService {
  @override
  Future<void> enable() => WakelockPlus.enable();

  @override
  Future<void> disable() => WakelockPlus.disable();
}

final screenAwakeServiceProvider = Provider<ScreenAwakeService>((ref) {
  return WakelockScreenAwakeService();
});
