package com.mealchemy.vault.service;

// models
import com.mealchemy.vault.model.RecipeEditLock;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.auth.model.User;

// dtos
import com.mealchemy.vault.dto.RecipeLockResponse;

// repositories
import com.mealchemy.vault.repository.RecipeEditLockRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.auth.repository.UserRepository;

// enums
import com.mealchemy.shared.enums.VaultMemberRole;

/* Import libraries */
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import org.springframework.dao.DataIntegrityViolationException;
import jakarta.persistence.EntityManager;
import java.time.OffsetDateTime;


@Service
public class RecipeEditLockService
{   
    private final RecipeEditLockRepository recipeEditLockRepository;
    private final RecipeRepository recipeRepository;
    private final VaultMemberRepository vaultMemberRepository;
    private final UserRepository userRepository;
    private final EntityManager entityManager;

    private static final long LOCK_TTL_SECONDS = 90;

    public RecipeEditLockService(RecipeEditLockRepository recipeEditLockRepository, RecipeRepository recipeRepository, VaultMemberRepository vaultMemberRepository, UserRepository userRepository, EntityManager entityManager)
    {
        this.recipeEditLockRepository = recipeEditLockRepository;
        this.recipeRepository = recipeRepository;
        this.vaultMemberRepository = vaultMemberRepository;
        this.userRepository = userRepository;
        this.entityManager = entityManager;
    }

    // Get lock
    public RecipeLockResponse getLock(Integer recipeId, Integer userId) 
    {
        // is recipe accessible to user
        recipeRepository.findAccessibleByIdAndUserId(recipeId, userId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        // looking up lock row - recipeId is PK (one lock per recipe)
        return recipeEditLockRepository.findById(recipeId)
                                        .filter(this::isActive)
                                        .map(RecipeLockResponse::from)
                                        .orElse(null);
    }

    // Acquire or refresh edit lock on a recipe. Only Owner or Editor roles in shared vault 
    @Transactional
    public RecipeLockResponse acquireLock(Integer recipeId, Integer userId) 
    {
        // is recipe accessible to user
        Recipe recipeForCheck = recipeRepository.findAccessibleByIdAndUserId(recipeId, userId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));
   
        // checks if user is owner 
        boolean isOwner = recipeForCheck.getOwnerId().equals(userId);

        if (!isOwner) // user is not the recipe owner (oerson that uploaded the recipe to the vault)
        {
            // checks if user is editor 
            requiresEditorRole(recipeId, userId);
        }

        // find existing recipe lock or existing lock is null
        RecipeEditLock existingLock = recipeEditLockRepository.findById(recipeId).orElse(null); 

        // another user already holds the live lock (lock is not free && lock is active && the existing lock is not locked by the user attempting to lock)
        if (existingLock != null && isActive(existingLock) && !existingLock.getLockedByUser().getUserId().equals(userId))
        {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "This recipe is currently being edited by another user.");
        }

        // user that holds the lock
        User lockHolder = userRepository.findById(userId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found."));

        // refreshing current user that holds the lock
        boolean isGenuineRefresh = existingLock != null && isActive(existingLock) && existingLock.getLockedByUser().getUserId().equals(userId);

        // declaring lock to save
        RecipeEditLock saved;

        if (isGenuineRefresh)
        {
            // same holder refreshing the lock - extends TTL and acquiredAt stays exactly the same
            existingLock.setExpiresAt(OffsetDateTime.now().plusSeconds(LOCK_TTL_SECONDS));
            saved = recipeEditLockRepository.save(existingLock);
        }
        else // no row exists (no current lock holder) or row is expired
        {
            // if the existing lock is not null but is locked by the current user - refresh the lock
            if (existingLock != null)
            {
                recipeEditLockRepository.delete(existingLock);
                recipeEditLockRepository.flush();
            }
            
            // there is no existing lock - new entry in db. Protect against concurrent attempt to acquire lock. Force INSERT to trigger db condition because of PK conflict
        
            RecipeEditLock newLock = new RecipeEditLock();
            newLock.setRecipeId(recipeId);
            newLock.setLockedByUser(lockHolder);
            newLock.setExpiresAt(OffsetDateTime.now().plusSeconds(LOCK_TTL_SECONDS));

            // force INSERT
            try 
            {
                entityManager.persist(newLock);
                entityManager.flush(); // force db constraint to be checked now
                saved = newLock;
            }
            catch(DataIntegrityViolationException e) 
            {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "This recipe is currently being edited by another user.");
            }
        }

        // TODO: Notification service mediator - broadcast that recipe is locked
        return RecipeLockResponse.from(saved);
    }


    // Delete - Release lock - lock holder only
    @Transactional
    public void releaseLock(Integer recipeId, Integer userId)
    {
        // is recipe accessible to user
        Recipe recipeForCheck = recipeRepository.findAccessibleByIdAndUserId(recipeId, userId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        // loading locked row
        RecipeEditLock existingLock = recipeEditLockRepository.findById(recipeId)
                            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No active lock on this recipe."));

        boolean isLockHolder = existingLock.getLockedByUser().getUserId().equals(userId);

        if (!isLockHolder)
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the lock holder can release this lock.");
        }

        recipeEditLockRepository.delete(existingLock);

        // TODO: Notification mediator
    }

    // ========= Helper function ==========

    // for recipe mutations
    public boolean canEditRecipe(Integer recipeId, Integer userId)
    {
        // is recipe accessible to user
        Recipe recipeForCheck = recipeRepository.findAccessibleByIdAndUserId(recipeId, userId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        boolean isOwner = recipeForCheck.getOwnerId().equals(userId);
        if (!isOwner)
        {
            requiresEditorRole(recipeId, userId);
        }

        RecipeEditLock activeLock = recipeEditLockRepository.findById(recipeId)
                                                            .filter(this::isActive)
                                                            .orElse(null);

        // if there is not an active lock or there is an active lock with the current user, they can edit
        if (activeLock == null || activeLock.getLockedByUser().getUserId().equals(userId))
        {
            return true;
        }

        throw new ResponseStatusException(HttpStatus.CONFLICT, "This recipe is currently being edited by another user.");
    }

    private void requiresEditorRole(Integer recipeId, Integer userId)
    {
        // check if user is an owner or editor
        VaultMember member = vaultMemberRepository.findVaultMembershipForRecipe(recipeId, userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found.")); 
                
        if (!member.getRole().equals(VaultMemberRole.EDITOR)) 
        {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."); 
        }
    }

    private boolean isActive(RecipeEditLock lock)
    {
        return lock.getExpiresAt().isAfter(OffsetDateTime.now());
    }

}