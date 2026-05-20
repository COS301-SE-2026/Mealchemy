package com.mealchemy.vault.model;

/* Import libraries */

import jakarta.persistence.*;
import java.time.OffsetDateTime;

/* Import classes */

import com.mealchemy.vault.model.VaultFolder;
import com.mealchemy.recipe.model.Recipe;

@Entity
@Table(name = "vault_folder_recipes")
public class VaultFolderRecipe {
    
    /* Declaring fields */

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "folder_id", nullable = false)
    private VaultFolder folder;

    @ManyToOne
    @JoinColumn(name = "recipe_id", nullable = false)
    private Recipe recipe;

    @Column(name = "added_at", nullable = false)
    private OffsetDateTime addedAt = OffsetDateTime.now();

    /* Getters */

    public VaultFolder getFolder()
    {
        return folder;
    }

    public Recipe getRecipe()
    {
        return recipe;
    }

    public OffsetDateTime getAddedAt()
    {
        return addedAt;
    }

    /* Setters */

    public void setFolder(VaultFolder folderIn)
    {
        folder = folderIn;
    }

    public void setRecipe(Recipe recipeIn)
    {
        recipe = recipeIn;
    }
}
