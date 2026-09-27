import 'package:dio/dio.dart';

import '../models/notification_page.dart';
import '../models/vault_notification.dart';
import 'notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  MockNotificationRepository({
    Iterable<VaultNotification> notifications = const [],
  }) {
    for (final notification in notifications) {
      _items[notification.notificationId] = notification;
    }
  }

  //each instance represents one user's inbox
  //no shared static state between users or tests
  final Map<int, VaultNotification> _items = {};

  @override
  Future<NotificationPage> getInbox({
    int page = 0,
    int size = 20,
  }) async {
    validateNotificationPageRequest(page, size);

    final sorted = _items.values.toList()
      ..sort((a, b) {
        final byTime = b.createdAt.compareTo(a.createdAt);
        return byTime != 0
            ? byTime
            : b.notificationId.compareTo(a.notificationId);
      });

    return NotificationPage(
      content: sorted.skip(page * size).take(size).toList(),
      number: page,
      size: size,
      totalPages: (sorted.length + size - 1) ~/ size,
      totalElements: sorted.length,
    );
  }

  @override
  Future<int> getUnreadCount() async {
    return _items.values.where((item) => !item.isRead).length;
  }

  @override
  Future<VaultNotification> markAsRead(int notificationId) async {
    validateNotificationId(notificationId);

    final existing = _items[notificationId];
    if (existing == null) {
      final request = RequestOptions(
        path: '/notifications/$notificationId/read',
        method: 'PATCH',
      );

      throw DioException(
        requestOptions: request,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: request,
          statusCode: 404,
          data: {'message': 'Notification not found.'},
        ),
      );
    }

    final updated = existing.withReadStatus(true);
    _items[notificationId] = updated;
    return updated;
  }

  @override
  Future<void> markAllAsRead() async {
    for (final id in _items.keys.toList()) {
      _items[id] = _items[id]!.withReadStatus(true);
    }
  }
}
