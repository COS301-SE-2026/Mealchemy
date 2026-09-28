import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/notifications/models/vault_live_event.dart';
import 'package:mealchemy/features/notifications/models/vault_notification.dart';
import 'package:mealchemy/features/notifications/services/notification_realtime_service.dart';
import 'package:mealchemy/features/notifications/services/notification_socket.dart';

class _Socket implements NotificationSocket {
  _Socket(this.token, this.callbacks);

  final String token;
  final NotificationSocketCallbacks callbacks;

  int activations = 0;
  int deactivations = 0;

  @override
  void activate() => activations++;

  @override
  void deactivate() => deactivations++;
}

class _Fixture {
  _Fixture() {
    service = NotificationRealtimeService(
      url: 'ws://localhost:8080/ws',
      socketFactory: (_, token, callbacks) {
        final socket = _Socket(token, callbacks);
        sockets.add(socket);
        return socket;
      },
      session: () => session,
      online: () => online,
      receiveNotification: notifications.add,
      reconcile: (includeInbox) async {
        refreshes.add(includeInbox);
      },
    );
  }

  NotificationSession? session = (userId: 7, token: 'first-token');
  bool online = true;

  final sockets = <_Socket>[];
  final notifications = <VaultNotification>[];
  final refreshes = <bool>[];

  late final NotificationRealtimeService service;
}

String _notification() => jsonEncode({
      'notificationId': 42,
      'type': 'RECIPE_ADDED',
      'message': 'A recipe was added.',
      'isRead': false,
      'actorUserId': 9,
      'refVaultId': 3,
      'refRecipeId': 118,
      'refInvitationId': null,
      'createdAt': '2026-09-26T14:03:12.481Z',
    });

String _lockEvent() => jsonEncode({
      'type': 'LOCK_ACQUIRED',
      'vaultId': 3,
      'recipeId': 118,
      'actorUserId': 9,
    });

void main() {
  test('builds the raw WebSocket URL from the backend origin', () {
    expect(
      notificationWebSocketUrl('http://localhost:8080'),
      'ws://localhost:8080/ws',
    );
    expect(
      notificationWebSocketUrl('https://api.example.com'),
      'wss://api.example.com/ws',
    );
    expect(
      () => notificationWebSocketUrl(
        'https://api.example.com?token=secret',
      ),
      throwsArgumentError,
    );
  });

  testWidgets('requires an authenticated foreground online session',
      (tester) async {
    final f = _Fixture();
    try {
      f.session = null;
      f.service.setForeground(true);
      expect(f.sockets, isEmpty);

      f.session = (userId: 7, token: 'first-token');
      f.online = false;
      f.service.update();
      expect(f.sockets, isEmpty);

      f.online = true;
      f.service.update();
      expect(f.sockets, hasLength(1));
      expect(f.sockets.single.activations, 1);

      f.sockets.single.callbacks.connected();
      expect(f.service.status, NotificationConnectionStatus.connected);
    } finally {
      f.service.dispose();
    }
  });

  testWidgets('notification pushes do not trigger REST refreshes',
      (tester) async {
    final f = _Fixture();
    try {
      f.service.setForeground(true);
      f.sockets.single.callbacks.connected();
      final refreshCount = f.refreshes.length;

      f.sockets.single.callbacks.notification(_notification());

      expect(f.notifications.single.notificationId, 42);
      expect(f.refreshes, hasLength(refreshCount));
    } finally {
      f.service.dispose();
    }
  });

  testWidgets('lock events are separate and malformed events are ignored',
      (tester) async {
    final f = _Fixture();
    final events = <VaultLiveEvent>[];
    final subscription = f.service.vaultEvents.listen(events.add);

    try {
      f.service.setForeground(true);
      final callbacks = f.sockets.single.callbacks;
      callbacks.connected();

      callbacks.notification('not json');
      callbacks.notification('[]');
      callbacks.vaultEvent('{}');
      callbacks.vaultEvent(_lockEvent());

      await tester.pump();

      expect(f.notifications, isEmpty);
      expect(events, hasLength(1));
      expect(events.single.type, VaultLiveEventType.lockAcquired);
      expect(events.single.recipeId, 118);
    } finally {
      await tester.runAsync(() async {
        await subscription.cancel();
        f.service.dispose();
      });
    }
  });

  testWidgets('error followed by close schedules only one reconnect',
      (tester) async {
    final f = _Fixture();
    try {
      f.service.setInboxVisible(true);
      f.service.setForeground(true);

      final first = f.sockets.single;
      first.callbacks.connected();
      first.callbacks.failed();
      first.callbacks.disconnected();

      expect(first.deactivations, 1);
      expect(f.service.status, NotificationConnectionStatus.reconnecting);

      await tester.pump(NotificationRealtimeService.retryDelay);

      expect(f.sockets, hasLength(2));
      f.sockets.last.callbacks.connected();
      expect(f.refreshes.last, isTrue);
    } finally {
      f.service.dispose();
    }
  });

  testWidgets('background disconnects and foreground reconciles',
      (tester) async {
    final f = _Fixture();
    try {
      f.service.setForeground(true);
      final first = f.sockets.single;
      first.callbacks.connected();

      f.service.setForeground(false);
      expect(first.deactivations, 1);

      first.callbacks.notification(_notification());
      await tester.pump(const Duration(seconds: 30));

      expect(f.notifications, isEmpty);
      expect(f.sockets, hasLength(1));

      final previousRefreshes = f.refreshes.length;
      f.service.setForeground(true);

      expect(f.sockets, hasLength(2));
      expect(f.refreshes.length, greaterThan(previousRefreshes));
      f.sockets.last.callbacks.connected();
    } finally {
      f.service.dispose();
    }
  });

  testWidgets('token changes replace the socket and reject stale callbacks',
      (tester) async {
    final f = _Fixture();
    try {
      f.service.setForeground(true);
      final first = f.sockets.single;
      first.callbacks.connected();

      f.session = (userId: 7, token: 'new-token');
      f.service.update();

      expect(first.deactivations, 1);
      expect(f.sockets.last.token, 'new-token');

      first.callbacks.notification(_notification());
      first.callbacks.failed();
      expect(f.notifications, isEmpty);

      f.sockets.last.callbacks.connected();
      f.sockets.last.callbacks.notification(_notification());
      expect(f.notifications, hasLength(1));
    } finally {
      f.service.dispose();
    }
  });

  testWidgets('logout disconnects and prevents stale delivery or retries',
      (tester) async {
    final f = _Fixture();
    try {
      f.service.setForeground(true);
      final first = f.sockets.single;
      first.callbacks.connected();

      f.session = null;
      f.service.update();

      first.callbacks.notification(_notification());
      first.callbacks.failed();
      await tester.pump(const Duration(seconds: 30));

      expect(first.deactivations, 1);
      expect(f.notifications, isEmpty);
      expect(f.sockets, hasLength(1));
    } finally {
      f.service.dispose();
    }
  });

  testWidgets('rejected token stays blocked until credentials change',
      (tester) async {
    final f = _Fixture();
    try {
      f.service.setForeground(true);
      f.sockets.single.callbacks.rejected();

      expect(f.service.status, NotificationConnectionStatus.rejected);

      f.service.setForeground(false);
      f.service.setForeground(true);

      f.online = false;
      f.service.update();
      f.online = true;
      f.service.update();

      await tester.pump(const Duration(seconds: 30));
      expect(f.sockets, hasLength(1));

      f.session = (userId: 7, token: 'replacement-token');
      f.service.update();

      expect(f.sockets, hasLength(2));
      expect(f.sockets.last.token, 'replacement-token');
      f.sockets.last.callbacks.connected();
    } finally {
      f.service.dispose();
    }
  });

  testWidgets('a stalled handshake times out and retries', (tester) async {
    final f = _Fixture();
    try {
      f.service.setForeground(true);

      await tester.pump(NotificationRealtimeService.connectTimeout);

      expect(f.sockets.single.deactivations, 1);
      expect(f.service.status, NotificationConnectionStatus.reconnecting);

      await tester.pump(NotificationRealtimeService.retryDelay);

      expect(f.sockets, hasLength(2));
      f.sockets.last.callbacks.connected();
    } finally {
      f.service.dispose();
    }
  });

  testWidgets('disposal cancels pending retries', (tester) async {
    final f = _Fixture();

    f.service.setForeground(true);
    f.sockets.single.callbacks.failed();
    f.service.dispose();

    await tester.pump(const Duration(seconds: 30));

    expect(f.sockets, hasLength(1));
  });
}
