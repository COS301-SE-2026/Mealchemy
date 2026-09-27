import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/notifications/models/vault_notification.dart';
import 'package:mealchemy/features/notifications/repositories/mock_notification_repository.dart';

VaultNotification _notification(int id, {bool isRead = false}) {
  return VaultNotification(
    notificationId: id,
    rawType: 'RECIPE_EDITED',
    message: 'Recipe $id was edited',
    isRead: isRead,
    actorUserId: 7,
    refVaultId: 3,
    refRecipeId: 100 + id,
    createdAt: DateTime.utc(2026, 9, 26, 10, id),
  );
}

void main() {
  test('returns newest notifications first across pages', () async {
    final repository = MockNotificationRepository(
      notifications: [
        _notification(1),
        _notification(3),
        _notification(2),
      ],
    );

    final first = await repository.getInbox(size: 2);
    final second = await repository.getInbox(page: 1, size: 2);

    expect(first.content.map((item) => item.notificationId), [3, 2]);
    expect(first.totalElements, 3);
    expect(first.totalPages, 2);
    expect(first.hasNext, isTrue);

    expect(second.content.single.notificationId, 1);
    expect(second.hasNext, isFalse);
  });

  test('supports empty inboxes and out-of-range pages', () async {
    final empty = MockNotificationRepository();

    expect(await empty.getUnreadCount(), 0);
    expect((await empty.getInbox()).content, isEmpty);
    expect((await empty.getInbox()).totalPages, 0);

    final repository = MockNotificationRepository(
      notifications: [_notification(1)],
    );

    final page = await repository.getInbox(page: 3);
    expect(page.content, isEmpty);
    expect(page.hasNext, isFalse);
  });

  test('mark-as-read is idempotent and does not change the source object',
      () async {
    final original = _notification(1);
    final repository = MockNotificationRepository(
      notifications: [original, _notification(2)],
    );

    expect(await repository.getUnreadCount(), 2);

    final updated = await repository.markAsRead(1);
    await repository.markAsRead(1);

    expect(updated.isRead, isTrue);
    expect(original.isRead, isFalse);
    expect(await repository.getUnreadCount(), 1);

    final page = await repository.getInbox();
    expect(
      page.content.singleWhere((item) => item.notificationId == 1).isRead,
      isTrue,
    );
  });

  test('mark-all-read is idempotent and preserves inbox history', () async {
    final repository = MockNotificationRepository(
      notifications: [
        _notification(1),
        _notification(2, isRead: true),
        _notification(3),
      ],
    );

    await repository.markAllAsRead();
    await repository.markAllAsRead();

    expect(await repository.getUnreadCount(), 0);

    final page = await repository.getInbox();
    expect(page.content, hasLength(3));
    expect(page.content.every((item) => item.isRead), isTrue);
  });

  test('separate mock instances have isolated inboxes', () async {
    final seed = _notification(1);
    final first = MockNotificationRepository(notifications: [seed]);
    final second = MockNotificationRepository(notifications: [seed]);

    await first.markAllAsRead();

    expect(await first.getUnreadCount(), 0);
    expect(await second.getUnreadCount(), 1);
  });

  test('missing notifications return a 404-style error', () async {
    final repository = MockNotificationRepository();

    await expectLater(
      repository.markAsRead(42),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'status',
          404,
        ),
      ),
    );
  });

  test('rejects invalid page sizes and IDs', () async {
    final repository = MockNotificationRepository();

    await expectLater(repository.getInbox(size: 51), throwsArgumentError);
    await expectLater(repository.getInbox(page: -1), throwsArgumentError);
    await expectLater(repository.markAsRead(0), throwsArgumentError);
  });
}
