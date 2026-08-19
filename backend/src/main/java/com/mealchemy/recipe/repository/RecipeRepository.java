package com.mealchemy.recipe.repository;

/* Import libraries */

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.*;

/* Import classes */

import com.mealchemy.recipe.model.Recipe;

@Repository
public interface RecipeRepository extends JpaRepository<Recipe, Integer>
{
    List<Recipe> findByIsCommunityPublishedTrue();

    @Query("""
        SELECT DISTINCT recipe
        FROM Recipe recipe
        WHERE recipe.ownerId = :userId
            OR recipe.isCommunityPublished = true
            OR EXISTS (
                SELECT folderRecipe.id
                FROM VaultFolderRecipe folderRecipe
                WHERE folderRecipe.recipe = recipe
                    AND (
                        folderRecipe.folder.vault.ownerId = :userId
                        OR EXISTS (
                            SELECT member.id
                            FROM VaultMember member
                            WHERE member.vault = folderRecipe.folder.vault
                                AND member.user.userId = :userId
                        )
                    )
            )
        """)
    
    // returns all recipes accessible through ownership, community publication, vault ownership, or vault membership
    List<Recipe> findAllAccessibleByUserId(@Param("userId") Integer userId);

    @Query("""
        SELECT DISTINCT recipe
        FROM Recipe recipe
        WHERE recipe.recipeId = :recipeId
            AND (
                recipe.ownerId = :userId
                OR recipe.isCommunityPublished = true
                OR EXISTS (
                    SELECT folderRecipe.id
                    FROM VaultFolderRecipe folderRecipe
                    WHERE folderRecipe.recipe = recipe
                        AND (
                            folderRecipe.folder.vault.ownerId = :userId
                            OR EXISTS (
                                SELECT member.id
                                FROM VaultMember member
                                WHERE member.vault = folderRecipe.folder.vault
                                    AND member.user.userId = :userId
                            )
                        )
                )
            )
        """)
    //same rules to one recipe
    //distinct to prevent duplicates
    Optional<Recipe> findAccessibleByIdAndUserId(
        @Param("recipeId") Integer recipeId,
        @Param("userId") Integer userId
    );
}
