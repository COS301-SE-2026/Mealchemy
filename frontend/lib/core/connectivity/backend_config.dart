import 'dart:io';

const String _configuredBackendUrl =
    String.fromEnvironment('BACKEND_URL', defaultValue: '');

String get backendBaseUrl {
  if (_configuredBackendUrl.isNotEmpty) return _configuredBackendUrl;
  return Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
}
