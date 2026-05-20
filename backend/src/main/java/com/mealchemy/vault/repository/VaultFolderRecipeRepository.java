package com.mealchemy.vault.repository;

/* Import libraries */

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.List;

/* Import classes */
import com.mealchemy.vault.model.VaultFolderRecipe;

public inteface VaultFolderRecipeRepository extends JpaRepository<VaultFolderRecipe, Long>
{
    List<VaultFolderRecipe> findByFolderId(Long folderId);
    List<VaultFolderRecipe> findByRecipeId(Long RecipeId);
}
