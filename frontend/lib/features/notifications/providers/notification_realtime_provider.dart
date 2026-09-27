import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/backend_config.dart';
import '../../../core/connectivity/network_status_provider.dart';
import '../../vault/providers/shared_vault_access_provider.dart';
import '../models/vault_live_event.dart';
import '../services/notification_realtime_service.dart';
import '../services/notification_socket.dart';
import 'notification_inbox_provider.dart';

final notificationSocketFactoryProvider =
    Provider<NotificationSocketFactory>((ref) {
  return (url, token, callbacks) => StompNotificationSocket(
        url: url,
        token: token,
        callbacks: callbacks,
      );
});

final notificationRealtimeProvider =
    Provider<NotificationRealtimeService>((ref) {
  final service = NotificationRealtimeService(
    url: notificationWebSocketUrl(backendBaseUrl),
    socketFactory: ref.watch(notificationSocketFactoryProvider),
    session: () {
      final session = ref.read(vaultSessionProvider);
      final userId = session.userId;
      final token = session.token;

      if (session.restoring ||
          !session.hasValidCredential ||
          userId == null ||
          token == null ||
          token.isEmpty) {
        return null;
      }

      return (userId: userId, token: token);
    },
    online: () => ref.read(vaultConnectionProvider) == NetworkStatus.online,
    receiveNotification: (notification) {
      ref
          .read(notificationInboxProvider.notifier)
          .receiveNotification(notification);
    },
    reconcile: (includeInbox) {
      return ref
          .read(notificationInboxProvider.notifier)
          .refresh(includeInbox: includeInbox);
    },
  );

  void scheduleUpdate() {
    unawaited(Future<void>.microtask(service.update));
  }

  ref.listen(vaultSessionProvider, (_, __) => scheduleUpdate());
  ref.listen(vaultConnectionProvider, (_, __) => scheduleUpdate());
  ref.onDispose(service.dispose);

  return service;
});

//live lock hints separate from stored inbox notifications
final vaultLiveEventsProvider =
    StreamProvider.autoDispose<VaultLiveEvent>((ref) {
  return ref.watch(notificationRealtimeProvider).vaultEvents;
});
