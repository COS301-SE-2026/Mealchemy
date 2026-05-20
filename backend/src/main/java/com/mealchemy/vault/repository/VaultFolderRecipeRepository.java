package com.mealchemy.vault.repository;

/* Import libraries */

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.List;

/* Import classes */
import com.mealchemy.vault.model.VaultFolderRecipe;

public interface VaultFolderRecipeRepository extends JpaRepository<VaultFolderRecipe, int>
{
    List<VaultFolderRecipe> findByFolderId(int folderId);
    List<VaultFolderRecipe> findByRecipeId(int RecipeId);
}
