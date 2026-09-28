import 'notification_json.dart';

enum VaultNotificationType {
  vaultInvite('VAULT_INVITE'),
  invitationAccepted('INVITATION_ACCEPTED'),
  invitationDeclined('INVITATION_DECLINED'),
  invitationCancelled('INVITATION_CANCELLED'),
  roleChanged('ROLE_CHANGED'),
  memberRemoved('MEMBER_REMOVED'),
  recipeAdded('RECIPE_ADDED'),
  recipeEdited('RECIPE_EDITED'),
  recipeRemoved('RECIPE_REMOVED'),
  folderCreated('FOLDER_CREATED'),
  folderDeleted('FOLDER_DELETED'),
  unknown('');

  const VaultNotificationType(this.wireValue);

  final String wireValue;

  static VaultNotificationType parse(String value) {
    for (final type in values) {
      if (type != unknown && type.wireValue == value) {
        return type;
      }
    }
    return unknown;
  }
}

class VaultNotification {
  const VaultNotification({
    required this.notificationId,
    required this.rawType,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.actorUserId,
    this.refVaultId,
    this.refRecipeId,
    this.refInvitationId,
  });

  final int notificationId;

  //preserve original value for future notification types
  final String rawType;
  final String message;
  final bool isRead;
  final int? actorUserId;
  final int? refVaultId;
  final int? refRecipeId;
  final int? refInvitationId;
  final DateTime createdAt;

  VaultNotificationType get type => VaultNotificationType.parse(rawType);

  factory VaultNotification.fromJson(Map<String, dynamic> json) {
    return VaultNotification(
      notificationId: NotificationJson.integer(
        json['notificationId'],
        'notificationId',
        minimum: 1,
      ),
      rawType: NotificationJson.text(json['type'], 'type'),
      // Keep the server's display text exactly as supplied.
      message: NotificationJson.text(json['message'], 'message'),
      isRead: NotificationJson.boolean(json['isRead'], 'isRead'),
      actorUserId: NotificationJson.optionalId(
        json['actorUserId'],
        'actorUserId',
      ),
      refVaultId: NotificationJson.optionalId(
        json['refVaultId'],
        'refVaultId',
      ),
      refRecipeId: NotificationJson.optionalId(
        json['refRecipeId'],
        'refRecipeId',
      ),
      refInvitationId: NotificationJson.optionalId(
        json['refInvitationId'],
        'refInvitationId',
      ),
      createdAt: NotificationJson.timestamp(json['createdAt'], 'createdAt'),
    );
  }

  VaultNotification withReadStatus(bool value) {
    return VaultNotification(
      notificationId: notificationId,
      rawType: rawType,
      message: message,
      isRead: value,
      actorUserId: actorUserId,
      refVaultId: refVaultId,
      refRecipeId: refRecipeId,
      refInvitationId: refInvitationId,
      createdAt: createdAt,
    );
  }
}
