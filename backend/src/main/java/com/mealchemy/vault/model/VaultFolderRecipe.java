package com.mealchemy.vault.model;

/* Import libraries */

import jakarta.persistence.*;
import java.time.OffsetDateTime;

/* Import classes */

@Entity
@Table(name = "vault_folder_recipes")
public class VaultFolderRecipe {
    
    /* Declaring fields */

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(name = "folder_id", nullable = false)
    private int folderId;

    @Column(name = "recipe_id", nullable = false)
    private int recipeId;

    @Column(name = "added_at", nullable = false)
    private OffsetDateTime addedAt = OffsetDateTime.now();

    /* Getters */

    public int getId()
    {
        return id;
    }

    public int getFolderId()
    {
        return folderId;
    }

    public int getRecipeId()
    {
        return recipeId;
    }

    public OffsetDateTime getAddedAt()
    {
        return addedAt;
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
