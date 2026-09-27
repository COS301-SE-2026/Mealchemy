package com.mealchemy.vault.event;

/* Import libraries */
 
import java.util.List;

/* Import classes */
 
import com.mealchemy.shared.enums.NotificationType;

public record NotificationEvent(
    List<Integer> recipientUserIds,
    Integer actorUserId, //can be null
    NotificationType type,
    String message,
    Integer refVaultId, 
    Integer refRecipeId,
    Integer refInvitationId
) {}