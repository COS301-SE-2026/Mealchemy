import 'package:dio/dio.dart';

import '../models/notification_json.dart';
import '../models/notification_page.dart';
import '../models/vault_notification.dart';
import 'notification_repository.dart';

class ApiNotificationRepository implements NotificationRepository {
  ApiNotificationRepository(this._dio);

  final Dio _dio;

  @override
  Future<NotificationPage> getInbox({
    int page = 0,
    int size = 20,
  }) async {
    validateNotificationPageRequest(page, size);

    final response = await _dio.get<dynamic>(
      '/notifications',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    _expectStatus(response, 200);

    final result = NotificationPage.fromJson(
      NotificationJson.object(response.data),
    );

    if (result.number != page || result.size != size) {
      throw const FormatException(
        'Notification response does not match the requested page.',
      );
    }

    return result;
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _dio.get<dynamic>(
      '/notifications/unread-count',
    );

    _expectStatus(response, 200);

    //backend returns bare JSON number, not object
    return NotificationJson.integer(response.data, 'unread count');
  }

  @override
  Future<VaultNotification> markAsRead(int notificationId) async {
    validateNotificationId(notificationId);

    final response = await _dio.patch<dynamic>(
      '/notifications/$notificationId/read',
    );

    _expectStatus(response, 200);

    final result = VaultNotification.fromJson(
      NotificationJson.object(response.data),
    );

    if (result.notificationId != notificationId || !result.isRead) {
      throw const FormatException(
        'Unexpected mark-notification-read response.',
      );
    }

    return result;
  }

  @override
  Future<void> markAllAsRead() async {
    final response = await _dio.patch<dynamic>(
      '/notifications/read-all',
    );

    _expectStatus(response, 204);
  }

  void _expectStatus(Response<dynamic> response, int expected) {
    if (response.statusCode != expected) {
      throw FormatException(
        'Unexpected notification response status: ${response.statusCode}.',
      );
    }
  }
}
