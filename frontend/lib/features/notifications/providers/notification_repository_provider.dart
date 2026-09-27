import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/api_service_provider.dart';
import '../repositories/api_notification_repository.dart';
import '../repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return ApiNotificationRepository(ref.watch(dioProvider));
});
