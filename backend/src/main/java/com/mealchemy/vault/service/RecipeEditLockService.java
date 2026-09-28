package com.mealchemy.vault.service;

// models
import com.mealchemy.vault.model.RecipeEditLock;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.auth.model.User;

// dtos
import com.mealchemy.vault.dto.RecipeLockResponse;

// repositories
import com.mealchemy.vault.repository.RecipeEditLockRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.auth.repository.UserRepository;

// events
import com.mealchemy.vault.event.NotificationEvent;
import com.mealchemy.vault.event.VaultLiveEvent;

// enums
import com.mealchemy.shared.enums.VaultMemberRole;
import com.mealchemy.shared.enums.NotificationType;
import com.mealchemy.shared.enums.VaultType;

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
    private final VaultRepository vaultRepository;
    private final UserRepository userRepository;
    private final EntityManager entityManager;
    private final NotificationService notificationService;

    private static final long LOCK_TTL_SECONDS = 90;

    public RecipeEditLockService(RecipeEditLockRepository recipeEditLockRepository, RecipeRepository recipeRepository, VaultMemberRepository vaultMemberRepository, 
        VaultRepository vaultRepository, UserRepository userRepository, EntityManager entityManager, NotificationService notificationService)
    {
        this.recipeEditLockRepository = recipeEditLockRepository;
        this.recipeRepository = recipeRepository;
        this.vaultMemberRepository = vaultMemberRepository;
        this.vaultRepository = vaultRepository;
        this.userRepository = userRepository;
        this.entityManager = entityManager;
        this.notificationService = notificationService;
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
   
        // can user edit recipe
        if (!hasEditorAccess(recipeForCheck, recipeId, userId))
        {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found.");
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
            // so refresh doesn't trigger notification
            return RecipeLockResponse.from(saved);
        }
        else // no row exists (no current lock holder) or row is expired
        {
            // if the existing lock is not null but is locked by the current user - refresh the lock
            if (existingLock != null)
            {
                notifyIfEdited(existingLock); // recipe has been edited

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

        // Notification
        publishLockEvent(NotificationType.LOCK_ACQUIRED, recipeId, userId);

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

        // Notification - before delete
        notifyIfEdited(existingLock);
        
        recipeEditLockRepository.delete(existingLock);

        // Notification
        publishLockEvent(NotificationType.LOCK_RELEASED, recipeId, userId);
    }

    // ========= Helper function ==========

    // for recipe mutations
    public boolean canEditRecipe(Integer recipeId, Integer userId)
    {
        // is recipe accessible to user
        Recipe recipeForCheck = recipeRepository.findAccessibleByIdAndUserId(recipeId, userId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        if (!hasEditorAccess(recipeForCheck, recipeId, userId))
        {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found.");

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

    private boolean hasEditorAccess(Recipe recipe, Integer recipeId, Integer userId)
    {
        if (recipe.getOwnerId().equals(userId))
        {
            return true;
        }

        Vault vault = vaultRepository.findVaultByRecipeId(recipeId).orElse(null);
        if (vault == null)
        {
            return false;
        }

        // is vault owner
        if (vault != null && vault.getOwnerId().equals(userId))
        {
            return true;
        }

        return vaultMemberRepository.findVaultMembershipForRecipe(recipeId, userId)
                                    .map(member -> member.getRole() == VaultMemberRole.EDITOR)
                                    .orElse(false);
    }

    private boolean isActive(RecipeEditLock lock)
    {
        return lock.getExpiresAt().isAfter(OffsetDateTime.now());
    }

    // ========== Notification Helpers ==========

    // live lock event - to vault members except actor
    private void publishLockEvent(NotificationType type, Integer recipeId, Integer actorId)
    {
        Vault vault = vaultRepository.findVaultByRecipeId(recipeId).filter(v -> v.getVaultType() == VaultType.SHARED) // if vault is shared
                                                                   .orElse(null);

        if (vault == null)
        {
            return;
        }

        notificationService.publishLiveEvent(new VaultLiveEvent(
            notificationService.getVaultParticipantIds(vault.getVaultId(), actorId),
            type,
            vault.getVaultId(),
            recipeId,
            actorId
        ));
    }

    // For RECIPE_EDIT - recipe saved during lock session
    private void notifyIfEdited(RecipeEditLock lock)
    {
        Recipe recipe = recipeRepository.findById(lock.getRecipeId()).orElse(null);

        if (recipe == null || recipe.getUpdatedAt() == null || !recipe.getUpdatedAt().isAfter(lock.getAcquiredAt())) // recipe has not been updated or updae was before lock was acquired
        {
            return;
        }

        Vault vault = vaultRepository.findVaultByRecipeId(recipe.getRecipeId()).filter(v -> v.getVaultType() == VaultType.SHARED) // if vault is shared
                                                                   .orElse(null);

        if (vault == null)
        {
            return;
        }

        Integer editorId = lock.getLockedByUser().getUserId();

        String message = notificationService.getDisplayName(editorId) + " edited " + recipe.getTitle() + " in " + vault.getName();

        notificationService.publish(new NotificationEvent(
            notificationService.getVaultParticipantIds(vault.getVaultId(), editorId), // who receives it
            editorId, // actor
            NotificationType.RECIPE_EDITED,
            message,
            vault.getVaultId(),
            recipe.getRecipeId(), // recipeId
            null
        ));
    }
}