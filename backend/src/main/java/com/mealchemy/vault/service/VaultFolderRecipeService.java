package com.mealchemy.vault.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import java.util.stream.Collectors;
import java.util.List;
import org.springframework.web.server.*;
import org.springframework.http.*;
import org.springframework.transaction.annotation.Transactional;

/* Import classes */
import com.mealchemy.vault.model.VaultFolderRecipe;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.model.VaultFolder;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.model.RecipeIngredient;
import com.mealchemy.recipe.model.RecipeStep;
import com.mealchemy.recipe.model.RecipeEquipment;
import com.mealchemy.auth.model.User;
import com.mealchemy.vault.dto.VaultFolderRecipeResponse;
import com.mealchemy.vault.dto.VaultFolderRecipeRequest;
import com.mealchemy.vault.dto.VaultFolderRecipeMoveRequest;
import com.mealchemy.vault.repository.VaultFolderRecipeRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.vault.repository.VaultFolderRepository;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.recipe.repository.RecipeIngredientRepository;
import com.mealchemy.recipe.repository.RecipeStepRepository;
import com.mealchemy.recipe.repository.RecipeEquipmentRepository;

import com.mealchemy.vault.event.NotificationEvent;

import com.mealchemy.shared.enums.VaultType;
import com.mealchemy.shared.enums.NotificationType;

@Service
public class VaultFolderRecipeService {
    private final VaultFolderRecipeRepository vaultFolderRecipeRepository;

    private final RecipeRepository recipeRepository;

    private final RecipeIngredientRepository recipeIngredientRepository;

    private final RecipeStepRepository recipeStepRepository;

    private final RecipeEquipmentRepository recipeEquipmentRepository;

    private final VaultMemberRepository vaultMemberRepository;

    private final VaultFolderRepository vaultFolderRepository;

    private final UserRepository userRepository;

    private final NotificationService notificationService; 

    public VaultFolderRecipeService(VaultFolderRecipeRepository vaultFolderRecipeRepository, RecipeRepository recipeRepository, RecipeIngredientRepository recipeIngredientRepository, RecipeStepRepository recipeStepRepository, 
        RecipeEquipmentRepository recipeEquipmentRepository, VaultMemberRepository vaultMemberRepository, VaultFolderRepository vaultFolderRepository, UserRepository userRepository, NotificationService notificationService)
    {
        this.vaultFolderRecipeRepository = vaultFolderRecipeRepository;
        this.recipeRepository = recipeRepository;
        this.recipeIngredientRepository = recipeIngredientRepository;
        this.recipeStepRepository = recipeStepRepository;
        this.recipeEquipmentRepository = recipeEquipmentRepository;
        this.vaultMemberRepository = vaultMemberRepository;
        this.vaultFolderRepository = vaultFolderRepository;
        this.userRepository = userRepository;
        this.notificationService = notificationService;
    }

    // Get all recipes using folderId
    public List<VaultFolderRecipeResponse> getRecipesByFolderId(int folderId, Integer userId)
    {
        VaultFolder vaultFolderForCheck = vaultFolderRepository.findById(folderId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found."));
        Vault vaultForCheck = vaultFolderForCheck.getVault();

        isOwnerOrMember(vaultForCheck, userId, "Folder not found.");

        return vaultFolderRecipeRepository.findByFolder_FolderId(folderId).stream().map(VaultFolderRecipeResponse::from).collect(Collectors.toList());
    }

    // Get all folders containing a recipe
    public List<VaultFolderRecipeResponse> getFoldersByRecipeId(int recipeId, Integer userId)
    {
        Recipe recipeForCheck = recipeRepository.findById(recipeId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        if (!recipeForCheck.getOwnerId().equals(userId))
        {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found.");
        }

        return vaultFolderRecipeRepository.findByRecipe_RecipeId(recipeId).stream().map(VaultFolderRecipeResponse::from).collect(Collectors.toList());
    }

    // Get a single record by id
    public VaultFolderRecipeResponse getFolderRecipeById(int id, Integer userId)
    {
        VaultFolderRecipe vaultFolderRecipeForReturn = vaultFolderRecipeRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No record found."));
        Vault vaultForCheck = vaultFolderRecipeForReturn.getFolder().getVault();
        
        isOwnerOrMember(vaultForCheck, userId, "No record found.");
        
        return VaultFolderRecipeResponse.from(vaultFolderRecipeForReturn);
    }

    // Post create a new record
    @Transactional
    public VaultFolderRecipeResponse createVaultFolderRecipe(VaultFolderRecipeRequest request, Integer userId, Integer folderId)
    {
        VaultFolder vaultFolderForReturn = vaultFolderRepository.findById(folderId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found."));
        Vault vaultForCheck = vaultFolderForReturn.getVault();
        isOwnerOrMember(vaultForCheck, userId, "Folder not found.");

        Recipe recipeForReturn = recipeRepository.findAccessibleByIdAndUserId(request.recipeId(), userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));
            
        User userForReturn = userRepository.findById(userId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found."));

        // if vault is shared create and return clone else return recipe
        Recipe resulantRecipe = vaultForCheck.getVaultType().equals(VaultType.SHARED) ? findOrCreateSharedVaultClone(recipeForReturn, userId, vaultForCheck) : recipeForReturn;

        VaultFolderRecipe saved = vaultFolderRecipeRepository.save(mapRequestToEntity(vaultFolderForReturn, resulantRecipe, userForReturn));

        // Notification
        Recipe vaultRecipe = saved.getRecipe();

        String addMessage = notificationService.getDisplayName(userId) + " added " + vaultRecipe.getTitle() + " to " + vaultForCheck.getName(); 

        notificationService.publish(new NotificationEvent(
            notificationService.getVaultParticipantIds(vaultForCheck.getVaultId(), userId), // who receives it
            userId, // actor
            NotificationType.RECIPE_ADDED,
            addMessage,
            vaultForCheck.getVaultId(),
            vaultRecipe.getRecipeId(), // recipe
            null
        ));

        return VaultFolderRecipeResponse.from(saved);
    }


    // Put to update a record
    public VaultFolderRecipeResponse updateVaultFolderRecipe(int id, VaultFolderRecipeMoveRequest request, Integer userId)
    {
        VaultFolderRecipe vaultFolderRecipeForReturn = vaultFolderRecipeRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No record found."));

        isOwner(vaultFolderRecipeForReturn.getFolder().getVault(), userId, "No record found.");

        Integer currentVaultId = vaultFolderRecipeForReturn.getFolder().getVault().getVaultId();
        VaultFolder vaultFolderForCheck = vaultFolderRepository.findByVault_VaultIdAndFolderId(currentVaultId, request.folderId())
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "New folder not found."));

        vaultFolderRecipeForReturn.setFolder(vaultFolderForCheck);

        return VaultFolderRecipeResponse.from(vaultFolderRecipeRepository.save(vaultFolderRecipeForReturn));
    }

    // Delete a specific record using id
    @Transactional
    public void deleteVaultFolderRecipe(int id, Integer userId)
    {
        VaultFolderRecipe vaultFolderRecipeForReturn = vaultFolderRecipeRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No record found."));

        canDelete(vaultFolderRecipeForReturn.getFolder().getVault(), vaultFolderRecipeForReturn.getAddedBy().getUserId(), userId, "No record found.");

        Vault vault = vaultFolderRecipeForReturn.getFolder().getVault();
        Integer recipeId = vaultFolderRecipeForReturn.getRecipe().getRecipeId();
        String recipeTitle = vaultFolderRecipeForReturn.getRecipe().getTitle();

        vaultFolderRecipeRepository.deleteById(id);
        
        String removeMessage = notificationService.getDisplayName(userId) + " removed " + recipeTitle + " from " + vault.getName();

        notificationService.publish(new NotificationEvent(
            notificationService.getVaultParticipantIds(vault.getVaultId(), userId), // who receives it
            userId, // actor
            NotificationType.RECIPE_REMOVED,
            removeMessage,
            vault.getVaultId(),
            recipeId, // not a recipe
            null
        ));
        
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
    private void isOwnerOrMember(Vault vault, Integer userId, String notFoundMessage)
    {
        boolean isMember = vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(vault.getVaultId(), userId);

        boolean isOwner = vault.getOwnerId().equals(userId);

        if (!isOwner && !isMember)
        {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, notFoundMessage);
        }
    }

    private void isOwner(Vault vault, Integer ownerId, String notFoundMessage)
    {
        if (!vault.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, notFoundMessage);
        }
    }

    private void canDelete(Vault vault, Integer addedByUserId, Integer userId, String notFoundMessage)
    {
        boolean isMember = vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(vault.getVaultId(), userId);

        boolean isOwner = vault.getOwnerId().equals(userId);

        boolean isPersonWhoAdded = addedByUserId.equals(userId);

        if (!isOwner && !(isMember && isPersonWhoAdded))
        {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, notFoundMessage);
        }
    }

    // to clone a recipe when recipe is added to SHARED vault
    private Recipe cloneRecipe(Recipe source, Integer newOwnerId) 
    {
        // create new recipe to deep clone
        Recipe clone = new Recipe();

        clone.setOwnerId(newOwnerId);
        clone.setTitle(source.getTitle());
        clone.setDescription(source.getDescription());
        clone.setCuisineType(source.getCuisineType());
        clone.setPrepTimeMins(source.getPrepTimeMins());
        clone.setCookingTimeMins(source.getCookingTimeMins());
        clone.setServingSize(source.getServingSize());
        clone.setPhotoUrl(source.getPhotoUrl());
        clone.setVideoUrl(source.getVideoUrl());
        clone.setExternalUrl(source.getExternalUrl());
        clone.setIsCommunityPublished(false);
        clone.setParentRecipe(source);

        Recipe savedClone = recipeRepository.save(clone);

        // deep clone ingredients and steps
        List<RecipeIngredient> clonedIngedients = source.getIngredients().stream().map(sourceIngredient -> {
            RecipeIngredient ingredientClone = new RecipeIngredient();
            ingredientClone.setRecipe(savedClone);
            ingredientClone.setIngId(sourceIngredient.getIngId());
            ingredientClone.setQuantity(sourceIngredient.getQuantity());
            ingredientClone.setUnit(sourceIngredient.getUnit());
            ingredientClone.setSortOrder(sourceIngredient.getSortOrder());
            return ingredientClone;
        }).collect(Collectors.toList());

        List<RecipeStep> clonedSteps = source.getSteps().stream().map(sourceStep -> {
            RecipeStep stepClone = new RecipeStep();
            stepClone.setRecipe(savedClone);
            stepClone.setStepNr(sourceStep.getStepNr());
            stepClone.setContent(sourceStep.getContent());
            return stepClone;
        }).collect(Collectors.toList());

        List<RecipeEquipment> clonedEquipment = source.getEquipment().stream().map(sourceEquipment -> {
            RecipeEquipment equipmentClone = new RecipeEquipment();
            equipmentClone.setRecipe(savedClone);
            equipmentClone.setEquipment(sourceEquipment.getEquipment());
            return equipmentClone;
        }).collect(Collectors.toList());

        recipeIngredientRepository.saveAll(clonedIngedients);
        recipeStepRepository.saveAll(clonedSteps);
        recipeEquipmentRepository.saveAll(clonedEquipment);

        return savedClone;
    }

    // finds the already existing cloned recipe in shared vault or creates new clone
    private Recipe findOrCreateSharedVaultClone(Recipe source, Integer newOwnerId, Vault targetVault)
    {
        return recipeRepository.findExistingClone(source, newOwnerId, targetVault).orElseGet(() -> cloneRecipe(source, newOwnerId));
    }
}
