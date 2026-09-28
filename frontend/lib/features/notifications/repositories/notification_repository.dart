import '../models/notification_page.dart';
import '../models/vault_notification.dart';

abstract class NotificationRepository {
  Future<NotificationPage> getInbox({
    int page = 0,
    int size = 20,
  });

  Future<int> getUnreadCount();

  Future<VaultNotification> markAsRead(int notificationId);

  Future<void> markAllAsRead();
}

void validateNotificationPageRequest(int page, int size) {
  if (page < 0) {
    throw ArgumentError.value(page, 'page', 'Must not be negative.');
  }

  if (size < 1 || size > 50) {
    throw ArgumentError.value(size, 'size', 'Must be between 1 and 50.');
  }
}

void validateNotificationId(int notificationId) {
  if (notificationId <= 0) {
    throw ArgumentError.value(
      notificationId,
      'notificationId',
      'Must be positive.',
    );
  }
}
