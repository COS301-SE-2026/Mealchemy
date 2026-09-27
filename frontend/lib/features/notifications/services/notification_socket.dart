import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

abstract class NotificationSocket {
  void activate();
  void deactivate();
}

class NotificationSocketCallbacks {
  const NotificationSocketCallbacks({
    required this.connected,
    required this.notification,
    required this.vaultEvent,
    required this.disconnected,
    required this.failed,
    required this.rejected,
  });

  final void Function() connected;
  final void Function(String body) notification;
  final void Function(String body) vaultEvent;
  final void Function() disconnected;
  final void Function() failed;
  final void Function() rejected;
}

typedef NotificationSocketFactory = NotificationSocket Function(
  String url,
  String token,
  NotificationSocketCallbacks callbacks,
);

String notificationWebSocketUrl(String backendUrl) {
  final uri = Uri.parse(backendUrl);

  if (!['http', 'https'].contains(uri.scheme) ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment) {
    throw ArgumentError.value(
      backendUrl,
      'backendUrl',
      'Expected an HTTP or HTTPS backend URL without credentials or queries.',
    );
  }

  return uri
      .replace(
        scheme: uri.scheme == 'https' ? 'wss' : 'ws',
        path: '/ws',
      )
      .toString();
}

class StompNotificationSocket implements NotificationSocket {
  StompNotificationSocket({
    required String url,
    required String token,
    required NotificationSocketCallbacks callbacks,
    StompClient Function(StompConfig config)? createClient,
  }) {
    final config = StompConfig(
      url: url,
      stompConnectHeaders: {
        'Authorization': 'Bearer $token',
      },

      //service owns retries so rejected tokens cannot retry forever
      reconnectDelay: Duration.zero,

      //backend does not provide STOMP heartbeats
      heartbeatIncoming: Duration.zero,
      heartbeatOutgoing: Duration.zero,
      connectionTimeout: const Duration(seconds: 10),
      onConnect: (_) {
        if (!_active) return;

        try {
          _client.subscribe(
            destination: '/user/queue/notifications',
            callback: (frame) => _deliver(frame, callbacks.notification),
          );

          _client.subscribe(
            destination: '/user/queue/vault-events',
            callback: (frame) => _deliver(frame, callbacks.vaultEvent),
          );

          callbacks.connected();
        } catch (_) {
          if (_active) callbacks.failed();
        }
      },
      onWebSocketDone: () {
        if (_active) callbacks.disconnected();
      },
      onWebSocketError: (_) {
        if (_active) callbacks.failed();
      },
      onDisconnect: (_) {
        if (_active) callbacks.disconnected();
      },
      onStompError: (_) {
        //auth and forbidden subscriptions produce ERROR frames
        //neither should be retried repeatedly with same credentials
        if (_active) callbacks.rejected();
      },
    );

    _client = createClient?.call(config) ?? StompClient(config: config);
  }

  late final StompClient _client;
  bool _active = false;

  void _deliver(StompFrame frame, void Function(String) callback) {
    if (!_active) return;

    String? body;

    try {
      body = frame.body;
      if (body == null && frame.binaryBody != null) {
        body = utf8.decode(frame.binaryBody!);
      }
    } on FormatException {
      return;
    }

    if (body != null) callback(body);
  }

  @override
  void activate() {
    _active = true;
    _client.activate();
  }

  @override
  void deactivate() {
    _active = false;
    _client.deactivate();
  }
}
