package com.mealchemy.vault.dto;
 
/* Import libraries */
 
import java.time.OffsetDateTime;
 
/* Import classes */
import com.mealchemy.vault.model.Notification;
import com.mealchemy.shared.enums.NotificationType;

public record NotificationResponse(
    Integer notificationId,
    NotificationType type,
    String message,
    Boolean isRead,
    Integer actorUserId, // null if actor's account deleted or no clear actor
    Integer refVaultId, 
    Integer refRecipeId,
    Integer refInvitationId,
    OffsetDateTime createdAt
)
{
    public static NotificationResponse from(Notification notification)
    {
        return new NotificationResponse(
            notification.getNotificationId(),
            notification.getType(),
            notification.getMessage(),
            notification.getIsRead(),
            notification.getActor() != null ? notification.getActor().getUserId() : null,
            notification.getRefVaultId(),
            notification.getRefRecipeId(),
            notification.getRefInvitationId(),
            notification.getCreatedAt()
        );
    }
}