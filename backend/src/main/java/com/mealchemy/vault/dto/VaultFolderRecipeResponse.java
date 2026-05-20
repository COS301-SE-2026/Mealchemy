package com.mealchemy.vault.model;

/* Import libraries */

import java.time.OffsetDateTime;

/* Import classes */

public class VaultFolderRecipe {
    
    /* Declaring fields */
    private Long id;
    private Long folderId;
    private Long recipeId;
    private OffsetDateTime addedAt;

    /* Getters */

    public Long getId()
    {
        return id;
    }

    public Long getFolderId()
    {
        return folderId;
    }

    public Long getRecipe()
    {
        return recipeId;
    }

    public OffsetDateTime getAddedAt()
    {
        return addedAt;
    }

    /* Setters */

    public void setId(Long idIn)
    {
        id = idIn;
    }

    public void setFolderId(Long folderIdIn)
    {
        folderId = folderIdIn;
    }

    public void setRecipe(Long recipeIdIn)
    {
        recipeId = recipeIdIn;
    }

    public void setAddedAt(OffsetDateTime addedAtIn)
    {
        addedAt = addedAtIn;
    }
}
