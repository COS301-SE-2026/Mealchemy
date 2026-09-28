import 'dart:async';
import 'dart:convert';

import '../models/notification_json.dart';
import '../models/vault_live_event.dart';
import '../models/vault_notification.dart';
import 'notification_socket.dart';

typedef NotificationSession = ({int userId, String token});

enum NotificationConnectionStatus {
  stopped,
  connecting,
  connected,
  reconnecting,
  rejected,
}

class NotificationRealtimeService {
  NotificationRealtimeService({
    required String url,
    required NotificationSocketFactory socketFactory,
    required NotificationSession? Function() session,
    required bool Function() online,
    required void Function(VaultNotification) receiveNotification,
    required Future<void> Function(bool includeInbox) reconcile,
  })  : _url = url,
        _socketFactory = socketFactory,
        _session = session,
        _online = online,
        _receiveNotification = receiveNotification,
        _reconcile = reconcile;

  static const retryDelay = Duration(seconds: 5);
  static const connectTimeout = Duration(seconds: 15);

  final String _url;
  final NotificationSocketFactory _socketFactory;
  final NotificationSession? Function() _session;
  final bool Function() _online;
  final void Function(VaultNotification) _receiveNotification;
  final Future<void> Function(bool includeInbox) _reconcile;

  final _events = StreamController<VaultLiveEvent>.broadcast();
  final _connections = StreamController<int>.broadcast();
  int _connectionRevision = 0;

  Stream<int> get connections => _connections.stream;

  Stream<VaultLiveEvent> get vaultEvents => _events.stream;

  NotificationConnectionStatus status = NotificationConnectionStatus.stopped;

  NotificationSocket? _socket;
  NotificationSession? _currentSession;
  String? _rejectedToken;

  Timer? _retryTimer;
  Timer? _connectTimer;

  bool _foreground = false;
  bool _inboxVisible = false;
  bool _enabled = false;
  bool _disposed = false;
  int _generation = 0;

  bool get _canConnect =>
      !_disposed &&
      _foreground &&
      _online() &&
      _currentSession != null &&
      _session() == _currentSession;

  void setForeground(bool foreground) {
    if (_disposed || _foreground == foreground) return;
    _foreground = foreground;
    update();
  }

  void setInboxVisible(bool visible) {
    if (_disposed) return;

    final becameVisible = visible && !_inboxVisible;
    _inboxVisible = visible;

    if (becameVisible && _canConnect) {
      _refreshFromRest();
    }
  }

  // Called whenever authentication or connectivity changes.
  void update() {
    if (_disposed) return;

    final nextSession = _session();

    if (nextSession != _currentSession) {
      _stopConnection();
      _currentSession = nextSession;
      _enabled = false;

      // Keep a rejected token blocked through logout or background changes.
      // A genuinely new token permits another connection.
      if (nextSession != null && nextSession.token != _rejectedToken) {
        _rejectedToken = null;
      }
    }

    if (!_canConnect) {
      _enabled = false;
      _stopConnection();
      status = NotificationConnectionStatus.stopped;
      return;
    }

    if (!_enabled) {
      _enabled = true;
      _refreshFromRest();
    }

    if (_currentSession!.token == _rejectedToken) {
      status = NotificationConnectionStatus.rejected;
      return;
    }

    if (_socket == null && _retryTimer == null) {
      _connect();
    }
  }

  bool _isCurrent(int generation, NotificationSession session) {
    return _canConnect &&
        generation == _generation &&
        session == _currentSession;
  }

  void _refreshFromRest() {
    if (!_canConnect) return;

    // The inbox notifier handles REST failures and exposes its error state.
    unawaited(_reconcile(_inboxVisible));
  }

  void _connect() {
    if (!_canConnect) return;

    final session = _currentSession!;
    final generation = ++_generation;

    status = NotificationConnectionStatus.connecting;

    final callbacks = NotificationSocketCallbacks(
      connected: () {
        if (!_isCurrent(generation, session)) return;

        _connectTimer?.cancel();
        _connectTimer = null;
        status = NotificationConnectionStatus.connected;
        _connections.add(++_connectionRevision);

        // Messages missed while disconnected are recovered through REST.
        _refreshFromRest();
      },
      notification: (body) {
        if (!_isCurrent(generation, session)) return;

        VaultNotification notification;
        try {
          notification = VaultNotification.fromJson(
            NotificationJson.object(jsonDecode(body)),
          );
        } on FormatException {
          return;
        }

        _receiveNotification(notification);
      },
      vaultEvent: (body) {
        if (!_isCurrent(generation, session)) return;

        VaultLiveEvent event;
        try {
          event = VaultLiveEvent.fromJson(
            NotificationJson.object(jsonDecode(body)),
          );
        } on FormatException {
          return;
        }

        if (event.type != VaultLiveEventType.unknown) {
          _events.add(event);
        }
      },
      disconnected: () => _connectionFailed(generation, session),
      failed: () => _connectionFailed(generation, session),
      rejected: () {
        if (!_isCurrent(generation, session)) return;

        _rejectedToken = session.token;
        _stopConnection();
        status = NotificationConnectionStatus.rejected;
      },
    );

    try {
      _socket = _socketFactory(_url, session.token, callbacks);

      _connectTimer = Timer(
        connectTimeout,
        () => _connectionFailed(generation, session),
      );

      _socket!.activate();
    } catch (_) {
      _connectionFailed(generation, session);
    }
  }

  void _connectionFailed(
    int generation,
    NotificationSession session,
  ) {
    if (!_isCurrent(generation, session)) return;

    //invalidate callbacks before closing the socket, close callback may follow error callback, but it mustnt schedule a second retry
    _stopConnection();
    status = NotificationConnectionStatus.reconnecting;

    _retryTimer = Timer(retryDelay, () {
      _retryTimer = null;
      update();
    });
  }

  void _stopConnection() {
    _generation++;

    _retryTimer?.cancel();
    _retryTimer = null;

    _connectTimer?.cancel();
    _connectTimer = null;

    final socket = _socket;
    _socket = null;
    socket?.deactivate();
  }

  void dispose() {
    if (_disposed) return;

    _disposed = true;
    _stopConnection();
    unawaited(_events.close());
    unawaited(_connections.close());
  }
}
