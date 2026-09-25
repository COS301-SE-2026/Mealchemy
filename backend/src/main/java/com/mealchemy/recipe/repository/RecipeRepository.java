package com.mealchemy.recipe.repository;

/* Import libraries */

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.*;

/* Import classes */

import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.vault.model.Vault;

@Repository
public interface RecipeRepository extends JpaRepository<Recipe, Integer>, RecipeRepositoryCustom
{
    Recipe findByRecipeId(Integer recipeId);
    
    @Query("""
    SELECT DISTINCT recipe
    FROM Recipe recipe
    LEFT JOIN FETCH recipe.ingredients
    WHERE recipe.isCommunityPublished = true
    """)

    List<Recipe> findByIsCommunityPublishedTrue();

    @Query("""
    SELECT recipe
    FROM Recipe recipe
    WHERE recipe.isCommunityPublished = true
        AND recipe.videoUrl IS NOT NULL
        AND TRIM(recipe.videoUrl) <> ''
    ORDER BY recipe.createdAt DESC, recipe.recipeId DESC
    """)
    List<Recipe> findCommunitySizzles();

   //removed findAllAccessibleByUserId and findAccessibleByIdAndUserId - use custom recvipe repository


    // find clone of recipe this user already owns within this specific vault
    @Query("""
            SELECT DISTINCT r
            FROM Recipe r
            JOIN r.vaultFolderRecipes vfr
            WHERE r.ownerId = :newOwnerId
                AND r.parentRecipe = :source
                AND vfr.folder.vault = :targetVault
    """)
    Optional<Recipe> findExistingClone(@Param("source") Recipe source, @Param("newOwnerId") Integer newOwnerId, @Param("targetVault") Vault targetVault);
}
