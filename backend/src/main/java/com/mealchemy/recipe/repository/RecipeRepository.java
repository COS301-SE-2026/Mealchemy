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
public interface RecipeRepository extends JpaRepository<Recipe, Integer>
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

    @Query("""
        SELECT DISTINCT recipe
        FROM Recipe recipe
        WHERE (
                recipe.ownerId = :userId
                AND NOT EXISTS (
                SELECT lostAccess.id
                FROM VaultFolderRecipe lostAccess
                WHERE lostAccess.recipe = recipe
                    AND lostAccess.folder.vault.vaultType = com.mealchemy.shared.enums.VaultType.SHARED
                    AND lostAccess.folder.vault.ownerId <> :userId
                    AND NOT EXISTS (
                        SELECT stillMember.id
                        FROM VaultMember stillMember
                        WHERE stillMember.vault = lostAccess.folder.vault
                            AND stillMember.user.userId = :userId
                    )
                )
            )
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
    
    // returns all recipes accessible through ownership, (minus revoked shared vault ownership), community publication, vault ownership, or vault membership
    List<Recipe> findAllAccessibleByUserId(@Param("userId") Integer userId);

    @Query("""
        SELECT DISTINCT recipe
        FROM Recipe recipe
        WHERE recipe.recipeId = :recipeId
            AND (
                (
                    recipe.ownerId = :userId
                    AND NOT EXISTS (
                        SELECT lostAccess.id
                        FROM VaultFolderRecipe lostAccess
                        WHERE lostAccess.recipe = recipe
                            AND lostAccess.folder.vault.vaultType = com.mealchemy.shared.enums.VaultType.SHARED
                            AND lostAccess.folder.vault.ownerId <> :userId
                            AND NOT EXISTS (
                                SELECT stillMember.id
                                FROM VaultMember stillMember
                                WHERE stillMember.vault = lostAccess.folder.vault
                                    AND stillMember.user.userId = :userId
                            )
                    )
                )
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
