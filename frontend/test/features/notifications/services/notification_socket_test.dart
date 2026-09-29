import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:mealchemy/features/notifications/services/notification_socket.dart';

class _Client extends Fake implements StompClient {
  final subscriptions = <String, void Function(StompFrame)>{};

  int activations = 0;
  int deactivations = 0;

  @override
  void activate() => activations++;

  @override
  void deactivate() => deactivations++;

  @override
  StompUnsubscribe subscribe({
    required String destination,
    required StompFrameCallback callback,
    Map<String, String>? headers,
  }) {
    subscriptions[destination] = callback;
    return ({Map<String, String>? unsubscribeHeaders}) {};
  }
}

void main() {
  test('authenticates through CONNECT and subscribes to only user queues', () {
    final client = _Client();
    late StompConfig config;

    var connected = false;
    final notifications = <String>[];
    final events = <String>[];

    final socket = StompNotificationSocket(
      url: 'wss://api.example.com/ws',
      token: 'test-token',
      createClient: (value) {
        config = value;
        return client;
      },
      callbacks: NotificationSocketCallbacks(
        connected: () => connected = true,
        notification: notifications.add,
        vaultEvent: events.add,
        disconnected: () {},
        failed: () {},
        rejected: () {},
      ),
    );

    expect(config.url, 'wss://api.example.com/ws');
    expect(config.stompConnectHeaders, {
      'Authorization': 'Bearer test-token',
    });
    expect(config.webSocketConnectHeaders, isNull);
    expect(config.reconnectDelay, Duration.zero);
    expect(config.heartbeatIncoming, Duration.zero);
    expect(config.heartbeatOutgoing, Duration.zero);

    socket.activate();
    config.onConnect(StompFrame(command: 'CONNECTED', headers: {}));

    expect(client.activations, 1);
    expect(connected, isTrue);
    expect(
        client.subscriptions.keys,
        unorderedEquals([
          '/user/queue/notifications',
          '/user/queue/vault-events',
        ]));

    client.subscriptions['/user/queue/notifications']!(
      StompFrame(
        command: 'MESSAGE',
        headers: {},
        body: '{"notificationId":42}',
      ),
    );

    client.subscriptions['/user/queue/vault-events']!(
      StompFrame(
        command: 'MESSAGE',
        headers: {},
        binaryBody: Uint8List.fromList(
          utf8.encode('{"type":"LOCK_ACQUIRED"}'),
        ),
      ),
    );

    expect(notifications, ['{"notificationId":42}']);
    expect(events, ['{"type":"LOCK_ACQUIRED"}']);

    socket.deactivate();

    client.subscriptions['/user/queue/notifications']!(
      StompFrame(command: 'MESSAGE', headers: {}, body: 'stale'),
    );

    expect(notifications, hasLength(1));
    expect(client.deactivations, 1);
  });

  test('reports a STOMP rejection without enabling automatic retries', () {
    final client = _Client();
    late StompConfig config;
    var rejected = 0;

    final socket = StompNotificationSocket(
      url: 'ws://localhost:8080/ws',
      token: 'expired-token',
      createClient: (value) {
        config = value;
        return client;
      },
      callbacks: NotificationSocketCallbacks(
        connected: () {},
        notification: (_) {},
        vaultEvent: (_) {},
        disconnected: () {},
        failed: () {},
        rejected: () => rejected++,
      ),
    );

    socket.activate();

    config.onStompError(
      StompFrame(
        command: 'ERROR',
        headers: {'message': 'Invalid or expired token.'},
      ),
    );

    expect(rejected, 1);
    expect(config.reconnectDelay, Duration.zero);

    socket.deactivate();
  });
}
