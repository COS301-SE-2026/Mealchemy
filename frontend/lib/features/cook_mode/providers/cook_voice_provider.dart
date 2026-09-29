import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/cook_voice_service.dart';

final cookVoiceServiceProvider = Provider<CookVoiceService>((ref) {
  final service = SpeechToTextCookVoiceService();
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});
