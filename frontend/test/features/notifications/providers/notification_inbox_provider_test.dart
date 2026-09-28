import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mealchemy/core/connectivity/network_status_provider.dart';
import 'package:mealchemy/features/notifications/models/notification_page.dart';
import 'package:mealchemy/features/notifications/models/vault_notification.dart';
import 'package:mealchemy/features/notifications/providers/notification_inbox_provider.dart';
import 'package:mealchemy/features/notifications/providers/notification_repository_provider.dart';
import 'package:mealchemy/features/notifications/repositories/notification_repository.dart';
import 'package:mealchemy/features/vault/providers/shared_vault_access_provider.dart';

VaultNotification _item(int id, {bool isRead = false}) {
  return VaultNotification(
    notificationId: id,
    rawType: 'RECIPE_EDITED',
    message: 'Recipe $id was edited',
    isRead: isRead,
    createdAt: DateTime.utc(2026, 9, 27).add(Duration(minutes: id)),
    actorUserId: 7,
    refVaultId: 3,
    refRecipeId: 100 + id,
  );
}

NotificationPage _page(
  List<VaultNotification> items, {
  int number = 0,
  int totalPages = 1,
  int? totalElements,
}) {
  return NotificationPage(
    content: items,
    number: number,
    size: 20,
    totalPages: totalPages,
    totalElements: totalElements ?? items.length,
  );
}

class _Repository implements NotificationRepository {
  List<VaultNotification> items = [];
  int unreadCount = 0;

  int countCalls = 0;
  int markCalls = 0;
  int markAllCalls = 0;
  final List<int> requestedPages = [];

  Future<NotificationPage> Function(int page)? load;
  Future<int> Function()? count;
  Future<VaultNotification> Function(int id)? mark;
  Future<void> Function()? markAll;

  @override
  Future<NotificationPage> getInbox({
    int page = 0,
    int size = 20,
  }) async {
    requestedPages.add(page);

    final response = load;
    if (response != null) return response(page);

    return NotificationPage(
      content: items.skip(page * size).take(size).toList(),
      number: page,
      size: size,
      totalPages: (items.length + size - 1) ~/ size,
      totalElements: items.length,
    );
  }

  @override
  Future<int> getUnreadCount() async {
    countCalls++;
    final response = count;
    return response == null ? unreadCount : await response();
  }

  @override
  Future<VaultNotification> markAsRead(int notificationId) async {
    markCalls++;

    final response = mark;
    if (response != null) return response(notificationId);

    final index = items.indexWhere(
      (item) => item.notificationId == notificationId,
    );

    final updated = items[index].withReadStatus(true);
    items[index] = updated;
    unreadCount = items.where((item) => !item.isRead).length;

    return updated;
  }

  @override
  Future<void> markAllAsRead() async {
    markAllCalls++;

    final response = markAll;
    if (response != null) {
      await response();
      return;
    }

    items = items.map((item) => item.withReadStatus(true)).toList();
    unreadCount = 0;
  }
}

class _Fixture {
  final repository = _Repository();
  bool currentSession = true;
  NetworkStatus connection = NetworkStatus.online;

  late final notifier = NotificationInboxNotifier(
    repository: repository,
    isCurrentSession: () => currentSession,
    connection: () => connection,
  );

  Future<void> seed(List<VaultNotification> items) async {
    repository.items = items;
    repository.unreadCount = items.where((item) => !item.isRead).length;
    await notifier.refresh();
  }

  void dispose() => notifier.dispose();
}

VaultSession _session(int? userId) => (
      userId: userId,
      token: userId == null ? null : 'token-$userId',
      restoring: false,
      hasValidCredential: userId != null,
    );

void main() {
  test('loads the count without eagerly loading the inbox', () async {
    final fixture = _Fixture();
    addTearDown(fixture.dispose);

    fixture.repository.unreadCount = 12;

    await fixture.notifier.refreshUnreadCount();

    expect(fixture.notifier.state.unreadCount, 12);
    expect(fixture.notifier.state.countNeedsRefresh, isFalse);
    expect(fixture.repository.requestedPages, isEmpty);
    expect(fixture.notifier.state.hasLoadedInbox, isFalse);
  });

  test('loads pages and deduplicates overlapping notification IDs', () async {
    final fixture = _Fixture();
    addTearDown(fixture.dispose);

    fixture.repository.load = (page) async => page == 0
        ? _page([_item(3), _item(2)], totalPages: 2, totalElements: 3)
        : _page(
            [_item(2), _item(1)],
            number: 1,
            totalPages: 2,
            totalElements: 3,
          );

    await fixture.notifier.refreshInbox();
    await fixture.notifier.loadMore();
    await fixture.notifier.loadMore();

    expect(
      fixture.notifier.state.items.map((item) => item.notificationId),
      [3, 2, 1],
    );
    expect(fixture.repository.requestedPages, [0, 1]);
    expect(fixture.notifier.state.hasMore, isFalse);
  });

  test('coalesces repeated refresh requests', () async {
    final fixture = _Fixture();
    addTearDown(fixture.dispose);

    final pending = Completer<NotificationPage>();
    fixture.repository.load = (_) => pending.future;

    final first = fixture.notifier.refreshInbox();
    final second = fixture.notifier.refreshInbox();

    expect(fixture.repository.requestedPages, [0]);

    pending.complete(_page([_item(1)]));
    await Future.wait([first, second]);

    expect(fixture.notifier.state.items, hasLength(1));
  });

  test('a refresh supersedes an older pagination response', () async {
    final fixture = _Fixture();
    addTearDown(fixture.dispose);

    final pendingMore = Completer<NotificationPage>();
    var firstPage = _page([_item(3)], totalPages: 2, totalElements: 2);

    fixture.repository.load = (page) {
      return page == 0 ? Future.value(firstPage) : pendingMore.future;
    };

    await fixture.notifier.refreshInbox();

    final loadingMore = fixture.notifier.loadMore();

    firstPage = _page([_item(9)]);
    await fixture.notifier.refreshInbox();

    pendingMore.complete(
      _page([_item(1)], number: 1, totalPages: 2, totalElements: 2),
    );
    await loadingMore;

    expect(
      fixture.notifier.state.items.map((item) => item.notificationId),
      [9],
    );
  });

  test('pushes are deduplicated without triggering REST requests', () async {
    final fixture = _Fixture();
    addTearDown(fixture.dispose);

    await fixture.seed([_item(1)]);

    final pageCalls = fixture.repository.requestedPages.length;
    final countCalls = fixture.repository.countCalls;

    fixture.notifier.receiveNotification(_item(2));
    fixture.notifier.receiveNotification(_item(2));

    expect(fixture.notifier.state.unreadCount, 2);
    expect(fixture.notifier.state.items, hasLength(2));
    expect(fixture.repository.requestedPages.length, pageCalls);
    expect(fixture.repository.countCalls, countCalls);
  });

  test('a push survives an in-flight page that does not contain it', () async {
    final fixture = _Fixture();
    addTearDown(fixture.dispose);

    final pending = Completer<NotificationPage>();
    fixture.repository.load = (_) => pending.future;

    final loading = fixture.notifier.refreshInbox();

    fixture.notifier.receiveNotification(_item(2));
    pending.complete(_page([_item(1)]));

    await loading;

    expect(
      fixture.notifier.state.items.map((item) => item.notificationId),
      [2, 1],
    );
  });

  test('an older count response does not overwrite a newer push', () async {
    final fixture = _Fixture();
    addTearDown(fixture.dispose);

    await fixture.seed([_item(1)]);

    final pending = Completer<int>();
    fixture.repository.count = () => pending.future;

    final refreshing = fixture.notifier.refreshUnreadCount();
    fixture.notifier.receiveNotification(_item(2));

    pending.complete(1);
    await refreshing;

    expect(fixture.notifier.state.unreadCount, 2);
    expect(fixture.notifier.state.countNeedsRefresh, isTrue);

    fixture.repository.count = null;
    fixture.repository.unreadCount = 2;

    await fixture.notifier.refreshUnreadCount();

    expect(fixture.notifier.state.countNeedsRefresh, isFalse);
  });

  test('marks read optimistically and prevents duplicate writes', () async {
    final fixture = _Fixture();
    addTearDown(fixture.dispose);

    await fixture.seed([_item(1)]);

    final pending = Completer<VaultNotification>();
    fixture.repository.mark = (_) => pending.future;

    final saving = fixture.notifier.markAsRead(1);

    expect(fixture.notifier.state.items.single.isRead, isTrue);
    expect(fixture.notifier.state.unreadCount, 0);
    expect(fixture.notifier.state.markingReadId, 1);

    expect(await fixture.notifier.markAsRead(1), isFalse);
    expect(fixture.repository.markCalls, 1);

    fixture.repository.unreadCount = 0;
    pending.complete(_item(1, isRead: true));

    expect(await saving, isTrue);
    expect(fixture.notifier.state.markingReadId, isNull);

    //delayed unread push must not undo confirmed read
    fixture.notifier.receiveNotification(_item(1));

    expect(fixture.notifier.state.items.single.isRead, isTrue);
    expect(fixture.notifier.state.unreadCount, 0);
  });

  test('failed read rolls back without removing a concurrent push', () async {
    final fixture = _Fixture();
    addTearDown(fixture.dispose);

    await fixture.seed([_item(1)]);

    final pending = Completer<VaultNotification>();
    fixture.repository.mark = (_) => pending.future;

    final saving = fixture.notifier.markAsRead(1);
    fixture.notifier.receiveNotification(_item(2));

    fixture.repository.unreadCount = 2;
    pending.completeError(Exception('Write failed'));

    expect(await saving, isFalse);
    expect(fixture.notifier.state.unreadCount, 2);
    expect(fixture.notifier.state.items, hasLength(2));
    expect(
      fixture.notifier.state.items
          .singleWhere((item) => item.notificationId == 1)
          .isRead,
      isFalse,
    );
    expect(fixture.notifier.state.actionError, isNotNull);
  });

  test('mark-all reconciles a notification received during the request',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.dispose);

    await fixture.seed([_item(1), _item(2)]);

    final pending = Completer<void>();
    fixture.repository.markAll = () => pending.future;

    final saving = fixture.notifier.markAllAsRead();

    expect(fixture.notifier.state.unreadCount, 0);
    expect(fixture.notifier.state.items.every((item) => item.isRead), isTrue);

    fixture.notifier.receiveNotification(_item(3));

    expect(fixture.notifier.state.unreadCount, 1);

    //in scenario the new row was created after server selected notifications covered by mark-all
    fixture.repository.items = [
      _item(3),
      _item(2, isRead: true),
      _item(1, isRead: true),
    ];
    fixture.repository.unreadCount = 1;

    pending.complete();
    expect(await saving, isTrue);

    expect(fixture.notifier.state.unreadCount, 1);
    expect(fixture.notifier.state.items.first.notificationId, 3);
    expect(fixture.notifier.state.items.first.isRead, isFalse);
    expect(fixture.repository.markAllCalls, 1);
  });

  test('failed mark-all restores read states and preserves new arrivals',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.dispose);

    await fixture.seed([_item(1), _item(2)]);

    final pending = Completer<void>();
    fixture.repository.markAll = () => pending.future;

    final saving = fixture.notifier.markAllAsRead();
    fixture.notifier.receiveNotification(_item(3));

    fixture.repository.unreadCount = 3;
    pending.completeError(Exception('Write failed'));

    expect(await saving, isFalse);
    expect(fixture.notifier.state.unreadCount, 3);
    expect(
      fixture.notifier.state.items.every((item) => !item.isRead),
      isTrue,
    );
  });

  test('failed refresh retains the previously loaded inbox', () async {
    final fixture = _Fixture();
    addTearDown(fixture.dispose);

    await fixture.seed([_item(1)]);

    fixture.repository.load = (_) async => throw Exception('Unavailable');

    await fixture.notifier.refreshInbox();

    expect(fixture.notifier.state.items.single.notificationId, 1);
    expect(fixture.notifier.state.inboxError, isNotNull);
    expect(fixture.notifier.state.isRefreshing, isFalse);
  });

  test('offline actions do not make requests or alter read status', () async {
    final fixture = _Fixture();
    addTearDown(fixture.dispose);

    await fixture.seed([_item(1)]);
    fixture.connection = NetworkStatus.offline;

    final calls = fixture.repository.requestedPages.length;

    await fixture.notifier.refreshInbox();
    expect(await fixture.notifier.markAsRead(1), isFalse);

    expect(fixture.repository.requestedPages.length, calls);
    expect(fixture.repository.markCalls, 0);
    expect(fixture.notifier.state.items.single.isRead, isFalse);
  });

  test('a response from an obsolete session is ignored', () async {
    final fixture = _Fixture();
    addTearDown(fixture.dispose);

    final pending = Completer<NotificationPage>();
    fixture.repository.load = (_) => pending.future;

    final loading = fixture.notifier.refreshInbox();
    fixture.currentSession = false;

    pending.complete(_page([_item(1)]));
    await loading;

    expect(fixture.notifier.state.items, isEmpty);
  });

  test('provider clears inbox state when the user logs out', () async {
    final sessionProvider = StateProvider<VaultSession>(
      (ref) => _session(1),
    );
    final repository = _Repository();

    final container = ProviderContainer(
      overrides: [
        vaultSessionProvider.overrideWith(
          (ref) => ref.watch(sessionProvider),
        ),
        vaultConnectionProvider.overrideWithValue(NetworkStatus.online),
        notificationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(notificationInboxProvider.notifier);
    await notifier.refreshUnreadCount();

    notifier.receiveNotification(_item(1));
    expect(container.read(notificationInboxProvider).items, hasLength(1));

    container.read(sessionProvider.notifier).state = _session(null);

    expect(container.read(notificationInboxProvider).items, isEmpty);
    expect(container.read(notificationInboxProvider).unreadCount, isNull);

    //signed-out provider mustnt fetch notification data
    final calls = repository.countCalls;
    await container
        .read(notificationInboxProvider.notifier)
        .refreshUnreadCount();

    expect(repository.countCalls, calls);
  });

  test('new session cannot receive the previous session count response',
      () async {
    final sessionProvider = StateProvider<VaultSession>(
      (ref) => _session(1),
    );

    final repository = _Repository();
    final oldCount = Completer<int>();
    repository.count = () => oldCount.future;

    final container = ProviderContainer(
      overrides: [
        vaultSessionProvider.overrideWith(
          (ref) => ref.watch(sessionProvider),
        ),
        vaultConnectionProvider.overrideWithValue(NetworkStatus.online),
        notificationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final oldNotifier = container.read(notificationInboxProvider.notifier);
    final oldRequest = oldNotifier.refreshUnreadCount();

    repository.count = () async => 2;
    container.read(sessionProvider.notifier).state = _session(2);

    final currentNotifier = container.read(notificationInboxProvider.notifier);
    await currentNotifier.refreshUnreadCount();

    oldCount.complete(99);
    await oldRequest;

    expect(container.read(notificationInboxProvider).unreadCount, 2);
    expect(container.read(notificationInboxProvider).items, isEmpty);
  });
}
