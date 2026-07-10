package com.mealchemy.vault.dto;

/* Import libraries */

import java.time.OffsetDateTime;

/* Import classes */

public record VaultFolderRecipeRequest(
    @NotNull int folderId,
    @NotNull int recipeId
){
}