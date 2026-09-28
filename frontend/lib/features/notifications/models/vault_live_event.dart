import 'notification_json.dart';

enum VaultLiveEventType {
  lockAcquired,
  lockReleased,
  unknown,
}

class VaultLiveEvent {
  const VaultLiveEvent({
    required this.rawType,
    required this.vaultId,
    required this.recipeId,
    required this.actorUserId,
  });

  final String rawType;
  final int vaultId;
  final int recipeId;
  final int actorUserId;

  VaultLiveEventType get type => switch (rawType) {
        'LOCK_ACQUIRED' => VaultLiveEventType.lockAcquired,
        'LOCK_RELEASED' => VaultLiveEventType.lockReleased,
        _ => VaultLiveEventType.unknown,
      };

  factory VaultLiveEvent.fromJson(Map<String, dynamic> json) {
    return VaultLiveEvent(
      rawType: NotificationJson.text(json['type'], 'type'),
      vaultId: NotificationJson.integer(
        json['vaultId'],
        'vaultId',
        minimum: 1,
      ),
      recipeId: NotificationJson.integer(
        json['recipeId'],
        'recipeId',
        minimum: 1,
      ),
      actorUserId: NotificationJson.integer(
        json['actorUserId'],
        'actorUserId',
        minimum: 1,
      ),
    );
  }
}
