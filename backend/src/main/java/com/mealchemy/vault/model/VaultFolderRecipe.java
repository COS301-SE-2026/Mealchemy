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
    private Long id;

    @Column(name = "folder_id", nullable = false)
    private Long folderId;

    @Column(name = "recipe_id", nullable = false)
    private Long recipeId;

    @Column(name = "added_at", nullable = false)
    private OffsetDateTime addedAt = OffsetDateTime.now();

    /* Getters */

    public Long getId()
    {
        return id;
    }

    public Long getFolderId()
    {
        return folderId;
    }

    public Recipe getRecipeId()
    {
        return recipeId;
    }

    public OffsetDateTime getAddedAt()
    {
        return addedAt;
    }

    /* Setters */

    public void setFolderId(Long folderIdIn)
    {
        folderId = folderIdIn;
    }

    public void setRecipeId(Recipe recipeIdIn)
    {
        recipeId = recipeIdIn;
    }
}
