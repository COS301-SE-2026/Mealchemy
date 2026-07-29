package com.mealchemy.vault.repository;

/* Import libraries */

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.List;

/* Import classes */
import com.mealchemy.vault.model.VaultFolderRecipe;

@Repository
public interface VaultFolderRecipeRepository extends JpaRepository<VaultFolderRecipe, Integer>
{
    List<VaultFolderRecipe> findByFolder_FolderId(int folderId);
    List<VaultFolderRecipe> findByRecipe_RecipeId(int recipeId);
}
