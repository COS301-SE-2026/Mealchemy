package com.mealchemy.vault.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import java.util.stream.Collectors;
import java.util.List;
import org.springframework.web.server.*;
import org.springframework.http.*;

/* Import classes */
import com.mealchemy.vault.model.VaultFolderRecipe;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.model.VaultFolder;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.auth.model.User;
import com.mealchemy.vault.dto.VaultFolderRecipeResponse;
import com.mealchemy.vault.dto.VaultFolderRecipeRequest;
import com.mealchemy.vault.dto.VaultFolderRecipeMoveRequest;
import com.mealchemy.vault.repository.VaultFolderRecipeRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.vault.repository.VaultFolderRepository;
import com.mealchemy.auth.repository.UserRepository;

@Service
public class VaultFolderRecipeService {
    private final VaultFolderRecipeRepository vaultFolderRecipeRepository;

    private final RecipeRepository recipeRepository;

    private final VaultMemberRepository vaultMemberRepository;

    private final VaultFolderRepository vaultFolderRepository;

    private final UserRepository userRepository;

    public VaultFolderRecipeService(VaultFolderRecipeRepository vaultFolderRecipeRepository, RecipeRepository recipeRepository, 
        VaultMemberRepository vaultMemberRepository, VaultFolderRepository vaultFolderRepository, UserRepository userRepository)
    {
        this.vaultFolderRecipeRepository = vaultFolderRecipeRepository;
        this.recipeRepository = recipeRepository;
        this.vaultMemberRepository = vaultMemberRepository;
        this.vaultFolderRepository = vaultFolderRepository;
        this.userRepository = userRepository;
    }

    // Get all recipes using folderId
    public List<VaultFolderRecipeResponse> getRecipesByFolderId(int folderId, Integer userId)
    {
        VaultFolder vaultFolderForCheck = vaultFolderRepository.findById(folderId).orElseThrow(() -> new RuntimeException("Folder not found."));
        Vault vaultForCheck = vaultFolderForCheck.getVault();

        isOwnerOrMember(vaultForCheck, userId);

        return vaultFolderRecipeRepository.findByFolder_FolderId(folderId).stream().map(VaultFolderRecipeResponse::from).collect(Collectors.toList());
    }

    // Get all folders containing a recipe
    public List<VaultFolderRecipeResponse> getFoldersByRecipeId(int recipeId, Integer userId)
    {
        Recipe recipeForCheck = recipeRepository.findById(recipeId).orElseThrow(() -> new RuntimeException("Recipe not found."));

        if (!recipeForCheck.getOwnerId().equals(userId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the recipe owner can see where it has been added.");
        }

        return vaultFolderRecipeRepository.findByRecipe_RecipeId(recipeId).stream().map(VaultFolderRecipeResponse::from).collect(Collectors.toList());
    }

    // Get a single record by id
    public VaultFolderRecipeResponse getFolderRecipeById(int id, Integer userId)
    {
        VaultFolderRecipe vaultFolderRecipeForReturn = vaultFolderRecipeRepository.findById(id).orElseThrow(() -> new RuntimeException("No record found."));
        Vault vaultForCheck = vaultFolderRecipeForReturn.getFolder().getVault();
        
        isOwnerOrMember(vaultForCheck, userId);
        
        return VaultFolderRecipeResponse.from(vaultFolderRecipeForReturn);
    }

    // Post create a new record
    public VaultFolderRecipeResponse createVaultFolderRecipe(VaultFolderRecipeRequest request, Integer userId, Integer folderId)
    {
        VaultFolder vaultFolderForReturn = vaultFolderRepository.findById(folderId).orElseThrow(() -> new RuntimeException("Folder not found."));
        Vault vaultForCheck = vaultFolderForReturn.getVault();
        isOwnerOrMember(vaultForCheck, userId);

        Recipe recipeForReturn = recipeRepository.findById(request.recipeId()).orElseThrow(() -> new RuntimeException("Recipe not found."));

        User userForReturn = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found."));

        VaultFolderRecipe vaultFolderRecipeForReturn = mapRequestToEntity(vaultFolderForReturn, recipeForReturn, userForReturn);
        return VaultFolderRecipeResponse.from(vaultFolderRecipeRepository.save(vaultFolderRecipeForReturn));
    }

    // Put to update a record
    public VaultFolderRecipeResponse updateVaultFolderRecipe(int id, VaultFolderRecipeMoveRequest request, Integer userId)
    {
        VaultFolderRecipe vaultFolderRecipeForReturn = vaultFolderRecipeRepository.findById(id).orElseThrow(() -> new RuntimeException("No record found."));

        isOwner(vaultFolderRecipeForReturn.getFolder().getVault(), userId);

        VaultFolder vaultFolderForCheck = vaultFolderRepository.findById(request.folderId()).orElseThrow(() -> new RuntimeException("New folder not found."));

        if(!vaultFolderForCheck.getVault().getVaultId().equals(vaultFolderRecipeForReturn.getFolder().getVault().getVaultId()))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Recipes can only moved between folders in the same vault.");
        }

        vaultFolderRecipeForReturn.setFolder(vaultFolderForCheck);

        return VaultFolderRecipeResponse.from(vaultFolderRecipeRepository.save(vaultFolderRecipeForReturn));
    }

    // Delete a specific record using id
    public void deleteVaultFolderRecipe(int id, Integer userId)
    {
        VaultFolderRecipe vaultFolderRecipeForReturn = vaultFolderRecipeRepository.findById(id).orElseThrow(() -> new RuntimeException("No record found."));

        canDelete(vaultFolderRecipeForReturn.getFolder().getVault(), vaultFolderRecipeForReturn.getAddedBy().getUserId(), userId);

        vaultFolderRecipeRepository.deleteById(id);
    }

    /* Mapping functions */

    private VaultFolderRecipe mapRequestToEntity(VaultFolder vaultFolderIn, Recipe recipeIn, User addedBy)
    {
        VaultFolderRecipe vaultFolderRecipe = new VaultFolderRecipe();

        vaultFolderRecipe.setFolder(vaultFolderIn);
        vaultFolderRecipe.setRecipe(recipeIn);
        vaultFolderRecipe.setAddedBy(addedBy);

        return vaultFolderRecipe;
    }

    /* Helpers */
    private void isOwnerOrMember(Vault vault, Integer userId)
    {
        boolean isMember = vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(vault.getVaultId(), userId);

        boolean isOwner = vault.getOwnerId().equals(userId);

        if (!isOwner && !isMember)
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only a vault member/owner can can interact with folders/recipe relationships.");
        }
    }

    private void isOwner(Vault vault, Integer ownerId)
    {
        if (!vault.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only a vault owner can interact with folders/recipe relationships.");
        }
    }

    private void canDelete(Vault vault, Integer addedByUserId, Integer userId)
    {
        boolean isMember = vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(vault.getVaultId(), userId);

        boolean isOwner = vault.getOwnerId().equals(userId);

        boolean isPersonWhoAdded = addedByUserId.equals(userId);

        if (!isOwner && !(isMember && isPersonWhoAdded))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only vault a member/owner can delete the folders.");
        }
    }
}
