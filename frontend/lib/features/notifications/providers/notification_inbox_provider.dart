import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../../vault/providers/shared_vault_access_provider.dart';
import '../models/notification_inbox_state.dart';
import '../models/vault_notification.dart';
import '../repositories/notification_repository.dart';
import 'notification_repository_provider.dart';

class NotificationInboxNotifier extends StateNotifier<NotificationInboxState> {
  NotificationInboxNotifier({
    required NotificationRepository repository,
    required bool Function() isCurrentSession,
    required NetworkStatus Function() connection,
  })  : _repository = repository,
        _isCurrentSession = isCurrentSession,
        _connection = connection,
        super(NotificationInboxState());

  static const pageSize = 20;

  final NotificationRepository _repository;
  final bool Function() _isCurrentSession;
  final NetworkStatus Function() _connection;

  final Map<int, VaultNotification> _items = {};

  //pushes can arrive before db transaction commits
  //preserve them until REST has returned corresponding row
  final Map<int, VaultNotification> _pendingPushes = {};

  final Set<int> _seenIds = {};

  //read status only moves from unread to read, keep confirmed reads from being reverted by older page or delayed duplicate push
  final Set<int> _confirmedReadIds = {};
  final Set<int> _optimisticReadIds = {};

  int? _unreadCount;
  bool _countNeedsRefresh = true;
  int _countRevision = 0;

  int _nextPage = 0;
  int _pageGeneration = 0;
  bool _hasLoadedInbox = false;
  bool _hasMore = false;
  bool _refreshing = false;
  bool _loadingMore = false;
  bool _refreshingCount = false;

  bool _markingAll = false;
  int? _markingReadId;

  //tracks pushes arriving during optimistic read operation, so rollback does not erase effect on badge
  int _mutationCountDelta = 0;

  String? _inboxError;
  String? _countError;
  String? _actionError;

  Future<void>? _refreshFuture;
  Future<void>? _moreFuture;
  Future<void>? _countFuture;

  bool get _active => mounted && _isCurrentSession();

  bool get _online => _connection() == NetworkStatus.online;

  bool get _writing => _markingAll || _markingReadId != null;

  VaultNotification _visible(VaultNotification item) {
    if (item.isRead ||
        _confirmedReadIds.contains(item.notificationId) ||
        _optimisticReadIds.contains(item.notificationId)) {
      return item.withReadStatus(true);
    }
    return item;
  }

  void _emit() {
    if (!_active) return;

    final items = _items.values.map(_visible).toList()
      ..sort((a, b) {
        final byTime = b.createdAt.compareTo(a.createdAt);
        return byTime != 0
            ? byTime
            : b.notificationId.compareTo(a.notificationId);
      });

    state = NotificationInboxState(
      items: items,
      unreadCount: _unreadCount,
      countNeedsRefresh: _countNeedsRefresh,
      hasLoadedInbox: _hasLoadedInbox,
      hasMore: _hasMore,
      isRefreshing: _refreshing,
      isLoadingMore: _loadingMore,
      isRefreshingCount: _refreshingCount,
      isMarkingAll: _markingAll,
      markingReadId: _markingReadId,
      inboxError: _inboxError,
      countError: _countError,
      actionError: _actionError,
    );
  }

  String _errorMessage(Object error, String fallback) {
    if (error is DioException) {
      switch (error.response?.statusCode) {
        case 401:
          return 'Sign in again to access your notifications.';
        case 404:
          return 'This notification is no longer available.';
      }
    }

    return fallback;
  }

  Future<void> refreshUnreadCount() {
    if (!_active) return Future<void>.value();

    final pending = _countFuture;
    if (pending != null) return pending;

    if (!_online) {
      _countNeedsRefresh = true;
      _countError = 'Connect to the internet to refresh notifications.';
      _emit();
      return Future<void>.value();
    }

    //don't overwrite optimistic count while a write is pending
    if (_writing) {
      _countNeedsRefresh = true;
      return Future<void>.value();
    }

    final future = _fetchUnreadCount();
    _countFuture = future;

    return future.whenComplete(() => _countFuture = null);
  }

  Future<void> _fetchUnreadCount() async {
    final revision = _countRevision;
    _refreshingCount = true;
    _countError = null;
    _emit();

    try {
      final count = await _repository.getUnreadCount();
      if (!_active) return;

      if (revision == _countRevision && !_writing) {
        _unreadCount = count;
        _countNeedsRefresh = false;
      } else {
        //push or read action happened during this request
        //without a server revision/cursor, response cannot afely replace newer local count
        _countNeedsRefresh = true;
      }
    } catch (error) {
      if (!_active) return;

      _countNeedsRefresh = true;
      _countError = _errorMessage(
        error,
        'Could not refresh the unread count. Try again.',
      );
    } finally {
      if (_active) {
        _refreshingCount = false;
        _emit();
      }
    }
  }

  Future<void> refreshInbox() {
    if (!_active) return Future<void>.value();

    final pending = _refreshFuture;
    if (pending != null) return pending;

    if (!_online) {
      _inboxError = 'Connect to the internet to load notifications.';
      _emit();
      return Future<void>.value();
    }

    final generation = ++_pageGeneration;
    _refreshing = true;
    _loadingMore = false;
    _inboxError = null;
    _emit();

    final future = _fetchPage(
      page: 0,
      generation: generation,
      replace: true,
    );
    _refreshFuture = future;

    return future.whenComplete(() => _refreshFuture = null);
  }

  Future<void> loadMore() {
    if (!_active || _refreshing) return Future<void>.value();

    if (!_hasLoadedInbox) return refreshInbox();

    final pending = _moreFuture;
    if (pending != null) return pending;

    if (!_hasMore) return Future<void>.value();

    if (!_online) {
      _inboxError = 'Connect to the internet to load more notifications.';
      _emit();
      return Future<void>.value();
    }

    _loadingMore = true;
    _inboxError = null;
    _emit();

    final future = _fetchPage(
      page: _nextPage,
      generation: _pageGeneration,
      replace: false,
    );
    _moreFuture = future;

    return future.whenComplete(() => _moreFuture = null);
  }

  Future<void> _fetchPage({
    required int page,
    required int generation,
    required bool replace,
  }) async {
    try {
      final result = await _repository.getInbox(
        page: page,
        size: pageSize,
      );

      if (!_active || generation != _pageGeneration) return;

      final merged = replace
          ? <int, VaultNotification>{}
          : Map<int, VaultNotification>.from(_items);

      for (final item in result.content) {
        _seenIds.add(item.notificationId);

        if (item.isRead) {
          _confirmedReadIds.add(item.notificationId);
        }

        merged[item.notificationId] = item;
        _pendingPushes.remove(item.notificationId);
      }

      //includes pushes received while REST request was running
      merged.addAll(_pendingPushes);

      _items
        ..clear()
        ..addAll(merged);

      _nextPage = result.number + 1;
      _hasMore = result.hasNext;
      _hasLoadedInbox = true;
    } catch (error) {
      if (!_active || generation != _pageGeneration) return;

      _inboxError = _errorMessage(
        error,
        'Could not load notifications. Try again.',
      );
    } finally {
      if (_active && generation == _pageGeneration) {
        if (replace) {
          _refreshing = false;
        } else {
          _loadingMore = false;
        }
        _emit();
      }
    }
  }

  //authenticated WebSocket service will call this
  //it performs no REST requests
  void receiveNotification(VaultNotification notification) {
    if (!_active) return;

    final id = notification.notificationId;
    final isNew = !_seenIds.contains(id);
    final previous = _items[id];
    final wasUnread = previous != null && !_visible(previous).isRead;

    if (notification.isRead) {
      _confirmedReadIds.add(id);
    }

    _seenIds.add(id);
    _items[id] = notification;
    _pendingPushes[id] = notification;

    final isUnread = !_visible(notification).isRead;

    var delta = 0;
    if (isNew && isUnread) {
      delta = 1;
    } else if (!isNew && wasUnread && !isUnread) {
      delta = -1;
    }

    if (_unreadCount != null) {
      _unreadCount = math.max(0, _unreadCount! + delta);
    }

    if (_writing) {
      _mutationCountDelta += delta;
    }

    _countRevision++;
    _countNeedsRefresh = true;
    _emit();
  }

  Future<bool> markAsRead(int notificationId) {
    validateNotificationId(notificationId);
    return _changeReadStatus(notificationId: notificationId);
  }

  Future<bool> markAllAsRead() {
    return _changeReadStatus();
  }

  Future<bool> _changeReadStatus({int? notificationId}) async {
    if (!_active || _writing) return false;

    if (!_online) {
      _actionError = 'Connect to the internet to mark notifications read.';
      _emit();
      return false;
    }

    if (notificationId != null) {
      final item = _items[notificationId];

      if (item == null) {
        _actionError = 'Refresh the inbox before opening this notification.';
        _emit();
        return false;
      }

      if (_visible(item).isRead) return true;
    }

    final affectedIds =
        notificationId == null ? _items.keys.toSet() : <int>{notificationId};

    final previousCount = _unreadCount;

    _markingAll = notificationId == null;
    _markingReadId = notificationId;
    _mutationCountDelta = 0;
    _actionError = null;

    _optimisticReadIds.addAll(affectedIds);

    if (_unreadCount != null) {
      _unreadCount =
          notificationId == null ? 0 : math.max(0, _unreadCount! - 1);
    }

    _countRevision++;
    _countNeedsRefresh = true;
    _emit();

    var succeeded = false;

    try {
      if (notificationId == null) {
        await _repository.markAllAsRead();
      } else {
        final updated = await _repository.markAsRead(notificationId);
        if (!_active) return false;
        _items[notificationId] = updated;
      }

      if (!_active) return false;

      _confirmedReadIds.addAll(affectedIds);
      succeeded = true;
    } catch (error) {
      if (!_active) return false;

      //preserve count effect of notifications received while failed optimistic operation in progress.
      _unreadCount = previousCount == null
          ? null
          : math.max(0, previousCount + _mutationCountDelta);

      _actionError = _errorMessage(
        error,
        'Could not update read status. Please try again.',
      );
    } finally {
      if (_active) {
        _optimisticReadIds.clear();
        _markingAll = false;
        _markingReadId = null;
        _countRevision++;
        _emit();
      }
    }

    if (!_active) return false;

    //reconcile uncertain outcomes and changes from other devices
    await refreshUnreadCount();

    if (_active && succeeded && notificationId == null && _hasLoadedInbox) {
      // A notification created during mark all may or may not have been included by server, reload to establish status
      await refreshInbox();
    }

    return _active && succeeded;
  }

  //used by pull to refresh and foreground/reconnect handling
  Future<void> refresh({bool includeInbox = true}) async {
    await Future.wait<void>([
      refreshUnreadCount(),
      if (includeInbox) refreshInbox(),
    ]);
  }
}

final notificationInboxProvider =
    StateNotifierProvider<NotificationInboxNotifier, NotificationInboxState>(
  (ref) {
    final session = ref.watch(vaultSessionProvider);

    bool isCurrentSession() {
      return ref.read(vaultSessionProvider) == session &&
          !session.restoring &&
          session.hasValidCredential &&
          session.userId != null &&
          session.token != null;
    }

    final notifier = NotificationInboxNotifier(
      repository: ref.watch(notificationRepositoryProvider),
      isCurrentSession: isCurrentSession,
      connection: () => ref.read(vaultConnectionProvider),
    );

    //start badge loading when the provider is first consumed
    unawaited(Future<void>.microtask(notifier.refreshUnreadCount));

    ref.listen(vaultConnectionProvider, (previous, next) {
      if (next == NetworkStatus.online && previous != next) {
        unawaited(notifier.refreshUnreadCount());
      }
    });

    return notifier;
  },
);
