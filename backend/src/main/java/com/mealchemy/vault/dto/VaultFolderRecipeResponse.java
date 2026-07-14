package com.mealchemy.vault.dto;

/* Import libraries */

import java.time.OffsetDateTime;

/* Import classes */

public record VaultFolderRecipeResponse(
    Integer id,
    Integer folderId,
    Integer recipeId,
    OffsetDateTime addedAt
)
{
    public static VaultFolderRecipeResponse from (VaultFolderRecipe vaultFolderRecipe)
    {
        return new VaultFolderRecipeResponse(
            vaultFolderRecipe.getId(),
            vaultFolderRecipe.getFolderId(),
            vaultFolderRecipe.getRecipeId(),
            vaultFolderRecipe.getAddedAt()
        );
    }
}