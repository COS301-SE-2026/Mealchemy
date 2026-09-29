package com.mealchemy.recipe.repository;

/* Import libraries */

import org.springframework.stereotype.Repository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.*;

/* Import classes */

import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.shared.enums.VaultType;

@Repository
public class RecipeRepositoryImpl implements RecipeRepositoryCustom
{
    @PersistenceContext
    private EntityManager entityManager;

    private final VaultRepository vaultRepository;
    private final VaultMemberRepository vaultMemberRepository;

    
    public RecipeRepositoryImpl(VaultRepository vaultRepository, VaultMemberRepository vaultMemberRepository)
    {
        this.vaultRepository = vaultRepository;
        this.vaultMemberRepository = vaultMemberRepository;
    }
    
   @Override
   public List<Recipe> findAllAccessibleByUserId(Integer userId)
   {
        List<Recipe> recipes = entityManager.createQuery("""
                    SELECT DISTINCT recipe FROM Recipe recipe
                    WHERE recipe.ownerId = :userId
                        OR recipe.isCommunityPublished = true
                        OR EXISTS (
                            SELECT folderRecipe.id FROM VaultFolderRecipe folderRecipe
                            WHERE folderRecipe.recipe = recipe
                                AND (folderRecipe.folder.vault.ownerId = :userId
                                    OR EXISTS (SELECT member.id FROM VaultMember member
                                        WHERE member.vault = folderRecipe.folder.vault
                                            AND member.user.userId = :userId))
                        )
                    """, Recipe.class)
                    .setParameter("userId", userId)
                    .getResultList();

        return recipes.stream()
                      .filter(recipe -> stillOwnsAccessibleCopy(recipe, userId)).toList();
   } 

   @Override
   public Optional<Recipe> findAccessibleByIdAndUserId(Integer recipeId, Integer userId)
   {
        return findAllAccessibleByUserId(userId).stream()
                                                .filter(recipe -> recipe.getRecipeId().equals(recipeId))
                                                .findFirst();
   } 

   // checks if a member is still in the shared vault
   private boolean stillOwnsAccessibleCopy(Recipe recipe, Integer userId) 
    {
        // user not owner of recipe
        if (!recipe.getOwnerId().equals(userId)) return true;
        
        // get the vault which recipe is part of
        Vault vault = vaultRepository.findVaultByRecipeId(recipe.getRecipeId()).orElse(null);
        // recipe is in private or global vault
        if (vault == null || vault.getVaultType() != VaultType.SHARED) return true;
        // user is vault owner
        if (vault.getOwnerId().equals(userId)) return true;

        return vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(vault.getVaultId(), userId);
    }

}
