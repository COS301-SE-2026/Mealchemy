import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/notifications/models/notification_page.dart';
import 'package:mealchemy/features/notifications/models/vault_live_event.dart';
import 'package:mealchemy/features/notifications/models/vault_notification.dart';

Map<String, dynamic> _notificationJson() => {
      'notificationId': 42,
      'type': 'RECIPE_ADDED',
      'message': 'Sofia added Pasta to Family Dinners',
      'isRead': false,
      'actorUserId': 7,
      'refVaultId': 3,
      'refRecipeId': 118,
      'refInvitationId': null,
      'createdAt': '2026-09-26T16:03:12.481+02:00',
    };

Map<String, dynamic> _pageJson({bool nested = false}) {
  final metadata = {
    'number': 0,
    'size': 20,
    'totalPages': 2,
    'totalElements': 21,
  };

  return {
    'content': [_notificationJson()],
    if (nested) 'page': metadata else ...metadata,
  };
}

void main() {
  test('parses references and normalizes the timestamp to UTC', () {
    final notification = VaultNotification.fromJson(_notificationJson());

    expect(notification.notificationId, 42);
    expect(notification.type, VaultNotificationType.recipeAdded);
    expect(notification.actorUserId, 7);
    expect(notification.refVaultId, 3);
    expect(notification.refRecipeId, 118);
    expect(notification.refInvitationId, isNull);
    expect(
      notification.createdAt,
      DateTime.utc(2026, 9, 26, 14, 3, 12, 481),
    );
    expect(notification.createdAt.isUtc, isTrue);
  });

  test('accepts deleted actors and absent optional reference IDs', () {
    final json = _notificationJson()
      ..['actorUserId'] = null
      ..remove('refRecipeId')
      ..remove('refInvitationId');

    final notification = VaultNotification.fromJson(json);

    expect(notification.actorUserId, isNull);
    expect(notification.refRecipeId, isNull);
    expect(notification.refInvitationId, isNull);
  });

  test('unknown types retain the original type and display message', () {
    final notification = VaultNotification.fromJson({
      ..._notificationJson(),
      'type': 'FUTURE_EVENT',
      'message': '  Original server message  ',
    });

    expect(notification.type, VaultNotificationType.unknown);
    expect(notification.rawType, 'FUTURE_EVENT');
    expect(notification.message, '  Original server message  ');
  });

  test('recognizes every supported inbox type', () {
    for (final type in VaultNotificationType.values) {
      if (type == VaultNotificationType.unknown) continue;

      final notification = VaultNotification.fromJson({
        ..._notificationJson(),
        'type': type.wireValue,
      });

      expect(notification.type, type);
    }
  });

  test('changing read status preserves notification data', () {
    final original = VaultNotification.fromJson(_notificationJson());
    final updated = original.withReadStatus(true);

    expect(original.isRead, isFalse);
    expect(updated.isRead, isTrue);
    expect(updated.notificationId, original.notificationId);
    expect(updated.rawType, original.rawType);
    expect(updated.message, original.message);
    expect(updated.createdAt, original.createdAt);
    expect(updated.actorUserId, original.actorUserId);
    expect(updated.refVaultId, original.refVaultId);
    expect(updated.refRecipeId, original.refRecipeId);
  });

  for (final invalid in <String, Object?>{
    'notificationId': 0,
    'type': '',
    'message': null,
    'isRead': 'false',
    'actorUserId': -1,
    'createdAt': '2026-09-26T14:03:12',
  }.entries) {
    test('rejects invalid ${invalid.key}', () {
      expect(
        () => VaultNotification.fromJson({
          ..._notificationJson(),
          invalid.key: invalid.value,
        }),
        throwsFormatException,
      );
    });
  }

  for (final nested in [false, true]) {
    test('parses ${nested ? "nested" : "top-level"} page metadata', () {
      final page = NotificationPage.fromJson(_pageJson(nested: nested));

      expect(page.content.single.notificationId, 42);
      expect(page.number, 0);
      expect(page.size, 20);
      expect(page.totalPages, 2);
      expect(page.totalElements, 21);
      expect(page.hasNext, isTrue);
      expect(() => page.content.clear(), throwsUnsupportedError);
    });
  }

  test('accepts an empty inbox', () {
    final page = NotificationPage.fromJson({
      'content': [],
      'number': 0,
      'size': 20,
      'totalPages': 0,
      'totalElements': 0,
    });

    expect(page.content, isEmpty);
    expect(page.hasNext, isFalse);
  });

  test('accepts an empty page beyond the last page', () {
    final page = NotificationPage.fromJson({
      'content': [],
      'number': 5,
      'size': 20,
      'totalPages': 1,
      'totalElements': 3,
    });

    expect(page.hasNext, isFalse);
  });

  test('does not treat missing pagination metadata as an empty inbox', () {
    expect(
      () => NotificationPage.fromJson({
        'content': [],
      }),
      throwsFormatException,
    );
  });

  test('rejects malformed notification items inside a page', () {
    expect(
      () => NotificationPage.fromJson({
        ..._pageJson(),
        'content': ['not an object'],
      }),
      throwsFormatException,
    );
  });

  test('parses live lock events separately from inbox notifications', () {
    final acquired = VaultLiveEvent.fromJson({
      'type': 'LOCK_ACQUIRED',
      'vaultId': 3,
      'recipeId': 118,
      'actorUserId': 7,
    });

    final released = VaultLiveEvent.fromJson({
      'type': 'LOCK_RELEASED',
      'vaultId': 3,
      'recipeId': 118,
      'actorUserId': 7,
    });

    expect(acquired.type, VaultLiveEventType.lockAcquired);
    expect(released.type, VaultLiveEventType.lockReleased);
    expect(acquired.recipeId, 118);
    expect(acquired.actorUserId, 7);
  });

  test('unknown live events can be identified and ignored', () {
    final event = VaultLiveEvent.fromJson({
      'type': 'FUTURE_LIVE_EVENT',
      'vaultId': 3,
      'recipeId': 118,
      'actorUserId': 7,
    });

    expect(event.type, VaultLiveEventType.unknown);
    expect(event.rawType, 'FUTURE_LIVE_EVENT');
  });

  test('rejects a live event with no recipe ID', () {
    expect(
      () => VaultLiveEvent.fromJson({
        'type': 'LOCK_ACQUIRED',
        'vaultId': 3,
        'actorUserId': 7,
      }),
      throwsFormatException,
    );
  });
}
