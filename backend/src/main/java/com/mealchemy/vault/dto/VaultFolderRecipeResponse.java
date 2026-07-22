package com.mealchemy.vault.dto;

/* Import libraries */

import java.time.OffsetDateTime;

/* Import classes */

import com.mealchemy.vault.model.VaultFolderRecipe;

public record VaultFolderRecipeResponse(
    Integer id,
    Integer folderId,
    Integer recipeId,
    OffsetDateTime addedAt,
    Integer addedByUserId
)
{
    public static VaultFolderRecipeResponse from (VaultFolderRecipe vaultFolderRecipe)
    {
        return new VaultFolderRecipeResponse(
            vaultFolderRecipe.getId(),
            vaultFolderRecipe.getFolder().getFolderId(),
            vaultFolderRecipe.getRecipe().getRecipeId(),
            vaultFolderRecipe.getAddedAt(),
            vaultFolderRecipe.getAddedBy() != null ? vaultFolderRecipe.getAddedBy().getUserId() : null
        );
    }
}