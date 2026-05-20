package com.mealchemy.vault.dto;

/* Import libraries */

import java.time.OffsetDateTime;

/* Import classes */

public class VaultFolderRecipeResponse {
    
    /* Declaring fields */
    private int id;
    private int folderId;
    private int recipeId;
    private OffsetDateTime addedAt;

    /* Getters */

    public int getId()
    {
        return id;
    }

    public int getFolderId()
    {
        return folderId;
    }

    public int getRecipe()
    {
        return recipeId;
    }

    public OffsetDateTime getAddedAt()
    {
        return addedAt;
    }

    /* Setters */

    public void setId(int idIn)
    {
        id = idIn;
    }

    public void setFolderId(int folderIdIn)
    {
        folderId = folderIdIn;
    }

    public void setRecipeId(int recipeIdIn)
    {
        recipeId = recipeIdIn;
    }

    public void setAddedAt(OffsetDateTime addedAtIn)
    {
        addedAt = addedAtIn;
    }
}
