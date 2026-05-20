package com.mealchemy.vault.dto;

/* Import libraries */

import java.time.OffsetDateTime;

/* Import classes */

public class VaultFolderRecipeRequest {
    
    /* Declaring fields */

    private int folderId;
    private int recipeId;

    /* Getters */

    public int getFolderId()
    {
        return folderId;
    }

    public int getRecipe()
    {
        return recipeId;
    }

    /* Setters */

    public void setFolderId(int folderIdIn)
    {
        folderId = folderIdIn;
    }

    public void setRecipeId(int recipeIdIn)
    {
        recipeId = recipeIdIn;
    }
}
