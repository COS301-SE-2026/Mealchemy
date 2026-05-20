package com.mealchemy.vault.model;

/* Import libraries */

import java.time.OffsetDateTime;

/* Import classes */

public class VaultFolderRecipeRequest {
    
    /* Declaring fields */

    private Long folderId;
    private Long recipeId;

    /* Getters */

    public Long getFolderId()
    {
        return folderId;
    }

    public Long getRecipe()
    {
        return recipeId;
    }

    /* Setters */

    public void setFolderId(Long folderIdIn)
    {
        folderId = folderIdIn;
    }

    public void setRecipeId(Long recipeIdIn)
    {
        recipeId = recipeIdIn;
    }
}
