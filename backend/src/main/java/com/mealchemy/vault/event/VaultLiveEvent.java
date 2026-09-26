package com.mealchemy.vault.event;

/* Import libraries */
 
import java.util.List;

/* Import classes */
 
import com.mealchemy.shared.enums.NotificationType;

public record VaultLiveEvent(
    List<Integer> recipientUserIds,
    NotificationType type,
    Integer vaultId,
    Integer recipeId,
    Integer actorUserId
) {}