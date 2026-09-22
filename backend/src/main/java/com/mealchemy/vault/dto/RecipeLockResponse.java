package com.mealchemy.vault.dto;

/* Import libraries */

import java.time.OffsetDateTime;
import jakarta.validation.constraints.*;

/* Import classes */

public record RecipeLockResponse(
    Integer recipeId,
    Integer lockedByUserId // current holder of the lock
    String lockedByEmail,
    OffsetDateTime acquiredAt,
    OffsetDateTime expiresAt 
)
{
    public static RecipeLockResponse from(RecipeEditLock lock)
    {
        return new RecipeLockResponse(
            lock.getRecipeId(),
            lock.getLockedByUser().getUserId(),
            lock.getLockedByUser().getEmail(),
            lock.getAcquiredAt(),
            lock.getExpiresAt()
        );
    }
}