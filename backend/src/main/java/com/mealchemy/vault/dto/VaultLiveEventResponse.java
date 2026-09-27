package com.mealchemy.vault.dto;

/* Import classes */
import com.mealchemy.vault.event.VaultLiveEvent;
import com.mealchemy.shared.enums.NotificationType;

public record VaultLiveEventResponse(
    NotificationType type,
    Integer vaultId,
    Integer recipeId,
    Integer actorUserId
) 
{
    public static VaultLiveEventResponse from(VaultLiveEvent event)
    {
        return new VaultLiveEventResponse(
            event.type(),
            event.vaultId(),
            event.recipeId(),
            event.actorUserId()
        );
    }
}