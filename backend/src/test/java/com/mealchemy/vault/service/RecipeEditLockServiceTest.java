package com.mealchemy.vault.service;

/* Importing libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import org.mockito.ArgumentCaptor;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import jakarta.persistence.EntityManager;

/* Import classes */
import com.mealchemy.vault.model.RecipeEditLock;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.repository.RecipeEditLockRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.vault.dto.RecipeLockResponse;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.auth.model.User;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.shared.enums.VaultMemberRole;
import com.mealchemy.shared.enums.VaultType;
import com.mealchemy.shared.enums.NotificationType;

import com.mealchemy.vault.event.NotificationEvent;
import com.mealchemy.vault.event.VaultLiveEvent;


@ExtendWith(MockitoExtension.class)
public class RecipeEditLockServiceTest {
    // @Mock - create fake version of dependency
    @Mock private RecipeEditLockRepository recipeEditLockRepository;
    @Mock private RecipeRepository recipeRepository;
    @Mock private VaultMemberRepository vaultMemberRepository;
    @Mock private VaultRepository vaultRepository;
    @Mock private UserRepository userRepository; 
    @Mock private EntityManager entityManager;
    @Mock private NotificationService notificationService;

    @InjectMocks
    private RecipeEditLockService recipeEditLockService;

    private Recipe ownedRecipe; // can be edited 
    private User owner;
    private User editor;
    private VaultMember editorMembership;
    private Vault sharedVault;

    @BeforeEach
    void setUp() 
    {
        // recipe
        ownedRecipe = new Recipe();
        ownedRecipe.setOwnerId(1);
        ReflectionTestUtils.setField(ownedRecipe, "recipeId", 1);

        // owner
        owner = new User();
        ReflectionTestUtils.setField(owner, "userId", 1);
        owner.setEmail("owner@email.com");

        // editor
        editor = new User();
        ReflectionTestUtils.setField(editor, "userId", 2);
        editor.setEmail("editor@email.com");

        editorMembership = new VaultMember();
        editorMembership.setRole(VaultMemberRole.EDITOR);

        sharedVault = new Vault();
        sharedVault.setOwnerId(1);
        sharedVault.setVaultType(VaultType.SHARED);
        ReflectionTestUtils.setField(sharedVault, "vaultId", 10);
    }

    // ========== Helpers =========

    private RecipeEditLock liveLock(User heldBy) 
    {
        RecipeEditLock lock = new RecipeEditLock();
        lock.setRecipeId(1);
        lock.setLockedByUser(heldBy);
        lock.setExpiresAt(OffsetDateTime.now().plusSeconds(90));
        return lock; 
    }

    private RecipeEditLock expiredLock(User heldBy) 
    {
        RecipeEditLock lock = new RecipeEditLock();
        lock.setRecipeId(1);
        lock.setLockedByUser(heldBy);
        lock.setExpiresAt(OffsetDateTime.now().minusSeconds(10));
        return lock; 
    }

    // ========= Tests ==========

    // Get lock
    @Test
    void getLock_noLockExists_returnNull() 
    {
        // Arrange
        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.of(ownedRecipe));
        when(recipeEditLockRepository.findById(1)).thenReturn(Optional.empty());

        // Act and Assert
        assertNull(recipeEditLockService.getLock(1, 1));
    }

    @Test
    void getLock_whenLiveLockExists_returnResponse()
    {
        // Arrange
        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.of(ownedRecipe));
        when(recipeEditLockRepository.findById(1)).thenReturn(Optional.of(liveLock(owner)));

        // Act
        RecipeLockResponse response = recipeEditLockService.getLock(1, 1);

        // Assert
        assertNotNull(response);
        assertEquals(1, response.lockedByUserId());
    }

    @Test
    void getLock_recipeNotAcessible_throwsExcepion() 
    {
        // Arrange
        when(recipeRepository.findAccessibleByIdAndUserId(99, 1)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> recipeEditLockService.getLock(99, 1)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }


    // Acquire lock
    @Test
    void acquireLock_ownerAndNoExistingLock_succeeds() 
    {
        // Arrange
        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.of(ownedRecipe));
        when(recipeEditLockRepository.findById(1)).thenReturn(Optional.empty());
        when(userRepository.findById(1)).thenReturn(Optional.of(owner));

        // Act
        RecipeLockResponse response = recipeEditLockService.acquireLock(1, 1);

        // Assert
        assertEquals(1, response.recipeId());
        assertEquals(1, response.lockedByUserId());
        verify(entityManager).persist(any(RecipeEditLock.class));
        verify(recipeEditLockRepository, never()).delete(any());
    }


    @Test
    void acquireLock_recipeNotAcessible_throwsExcepion() 
    {
        // Arrange
        when(recipeRepository.findAccessibleByIdAndUserId(99, 1)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> recipeEditLockService.acquireLock(99, 1)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        verifyNoInteractions(entityManager);
    }

    @Test
    void acquireLock_notOwnerOrEditor_throwsExcepion() 
    {
        // Arrange
        when(recipeRepository.findAccessibleByIdAndUserId(1, 99)).thenReturn(Optional.of(ownedRecipe));
        when(vaultRepository.findVaultByRecipeId(1)).thenReturn(Optional.of(sharedVault));
        when(vaultMemberRepository.findVaultMembershipForRecipe(1, 99)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> recipeEditLockService.acquireLock(1, 99)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        verifyNoInteractions(entityManager);
    }

    @Test
    void acquireLock_liveLockHeldByOtherUser_throwsConflict() 
    {
        // Arrange
        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.of(ownedRecipe));
        when(recipeEditLockRepository.findById(1)).thenReturn(Optional.of(liveLock(editor)));

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> recipeEditLockService.acquireLock(1, 1)
        );

        // Assert
        assertEquals(HttpStatus.CONFLICT, ex.getStatusCode());
        verifyNoInteractions(entityManager);
        verifyNoInteractions(notificationService);
    }


    @Test
    void acquireLock_userHoldLiveLockAlready_refresh() 
    {
        // Arrange
        RecipeEditLock existing = liveLock(owner);
        OffsetDateTime originalAcquiredAt = OffsetDateTime.now().minusMinutes(1);
        ReflectionTestUtils.setField(existing, "acquiredAt", originalAcquiredAt);
   
        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.of(ownedRecipe));
        when(recipeEditLockRepository.findById(1)).thenReturn(Optional.of(existing));
        when(userRepository.findById(1)).thenReturn(Optional.of(owner));
        when(recipeEditLockRepository.save(existing)).thenReturn(existing);

        // Act
        RecipeLockResponse response = recipeEditLockService.acquireLock(1, 1);

        // Assert
        assertEquals(1, response.recipeId());
        verify(recipeEditLockRepository).save(existing);
        verifyNoInteractions(entityManager);
        verify(recipeEditLockRepository, never()).delete(any());
        assertEquals(originalAcquiredAt, existing.getAcquiredAt());
        verifyNoInteractions(notificationService); // refresh doesn't trigger a notification
    }

    @Test
    void acquireLock_concurrentInsertAttempt_violatesDbConstraint_thowsConflict() 
    {
        // Arrange
        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.of(ownedRecipe));
        when(recipeEditLockRepository.findById(1)).thenReturn(Optional.empty());
        when(userRepository.findById(1)).thenReturn(Optional.of(owner));
        doThrow(new DataIntegrityViolationException("duplicate key")).when(entityManager).flush(); 

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> recipeEditLockService.acquireLock(1, 1)
        );

        // Assert
        assertEquals(HttpStatus.CONFLICT, ex.getStatusCode());
    }

    @Test 
    void acquireLock_editorDemotedToViewer_whileHoldingLock_rejectOnLockRefresh()
    {
        // Arrange
        VaultMember demotedMember = new VaultMember();
        demotedMember.setRole(VaultMemberRole.VIEWER);

        when(recipeRepository.findAccessibleByIdAndUserId(1, 2)).thenReturn(Optional.of(ownedRecipe));
        when(vaultRepository.findVaultByRecipeId(1)).thenReturn(Optional.of(sharedVault));
        when(vaultMemberRepository.findVaultMembershipForRecipe(1, 2)).thenReturn(Optional.of(demotedMember));

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> recipeEditLockService.acquireLock(1, 2)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        verifyNoInteractions(entityManager);
    }


    // release lock
    @Test
    void releaseLock_whenCallerIsHolder_deletesLock() 
    {
        // Arrange
        RecipeEditLock existing = liveLock(owner);

        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.of(ownedRecipe));
        when(recipeEditLockRepository.findById(1)).thenReturn(Optional.of(existing));

        // Act
        recipeEditLockService.releaseLock(1, 1);

        // Assert
        verify(recipeEditLockRepository).delete(existing);
    }

    @Test
    void releaseLock_whenNoLockExists_thrownsException() 
    {
        // Arrange
        RecipeEditLock existing = liveLock(owner);

        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.of(ownedRecipe));
        when(recipeEditLockRepository.findById(1)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> recipeEditLockService.releaseLock(1, 1)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void releaseLock_whenRecipeNotAccessible_thrownsException() 
    {
        // Arrange
        when(recipeRepository.findAccessibleByIdAndUserId(99, 1)).thenReturn(Optional.empty());
       
        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> recipeEditLockService.releaseLock(99, 1)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    
    // can edit recipe
    @Test
    void canEditRecipe_forOwner_whenNoLock_returnsTrue() 
    {
        // Arrange
        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.of(ownedRecipe));
        when(recipeEditLockRepository.findById(1)).thenReturn(Optional.empty());

        // Act and Assert
        assertTrue(recipeEditLockService.canEditRecipe(1, 1));
    }

    @Test
    void canEditRecipe_forEditor_whenNoLock_returnsTrue() 
    {
        // Arrange
        when(recipeRepository.findAccessibleByIdAndUserId(1, 2)).thenReturn(Optional.of(ownedRecipe));
        when(vaultRepository.findVaultByRecipeId(1)).thenReturn(Optional.of(sharedVault));
        when(vaultMemberRepository.findVaultMembershipForRecipe(1, 2)).thenReturn(Optional.of(editorMembership));
        when(recipeEditLockRepository.findById(1)).thenReturn(Optional.empty());

        // Act and Assert
        assertTrue(recipeEditLockService.canEditRecipe(1, 2));
    }

    @Test
    void canEditRecipe_forEditor_whenHoldingOwnLock_returnsTrue() 
    {
        // Arrange
        when(recipeRepository.findAccessibleByIdAndUserId(1, 2)).thenReturn(Optional.of(ownedRecipe));
        when(vaultRepository.findVaultByRecipeId(1)).thenReturn(Optional.of(sharedVault));
        when(vaultMemberRepository.findVaultMembershipForRecipe(1, 2)).thenReturn(Optional.of(editorMembership));
        when(recipeEditLockRepository.findById(1)).thenReturn(Optional.of(liveLock(editor)));

        // Act and Assert
        assertTrue(recipeEditLockService.canEditRecipe(1, 2));
    }

    @Test 
    void canEditRecipe_forVaultOwner_otherMembersRecipe_returnsTrue() 
    {
        // Arrange
        Recipe editorsCopy = new Recipe();
        editorsCopy.setOwnerId(2);
        ReflectionTestUtils.setField(editorsCopy, "recipeId", 1);

        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.of(editorsCopy));
        when(vaultRepository.findVaultByRecipeId(1)).thenReturn(Optional.of(sharedVault));
        when(recipeEditLockRepository.findById(1)).thenReturn(Optional.empty());

        // Act and Assert
        assertTrue(recipeEditLockService.canEditRecipe(1, 1));

    }

    @Test
    void canEditRecipe_forOwnerButLockHeldByEditor_throwsConflict() 
    {
        // Arrange
        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.of(ownedRecipe));
        when(recipeEditLockRepository.findById(1)).thenReturn(Optional.of(liveLock(editor)));

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> recipeEditLockService.canEditRecipe(1, 1)
        );

        // Assert
        assertEquals(HttpStatus.CONFLICT, ex.getStatusCode());
    }

    @Test
    void canEditRecipe_whenNotOwnerAndNotMember_throwsException()
    {
        // Arrange
        when(recipeRepository.findAccessibleByIdAndUserId(1, 99)).thenReturn(Optional.of(ownedRecipe));
        when(vaultRepository.findVaultByRecipeId(1)).thenReturn(Optional.of(sharedVault));
        when(vaultMemberRepository.findVaultMembershipForRecipe(1, 99)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> recipeEditLockService.canEditRecipe(1, 99)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void canEditRecipe_whenMemberButNotOwnerOrEditor_throwsException()
    {
        // Arrange
        VaultMember viewerMembership = new VaultMember();
        viewerMembership.setRole(VaultMemberRole.VIEWER);

        when(recipeRepository.findAccessibleByIdAndUserId(1, 3)).thenReturn(Optional.of(ownedRecipe));
        when(vaultRepository.findVaultByRecipeId(1)).thenReturn(Optional.of(sharedVault));
        when(vaultMemberRepository.findVaultMembershipForRecipe(1, 3)).thenReturn(Optional.of(viewerMembership));

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> recipeEditLockService.canEditRecipe(1, 3)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }


    

    // ========== Notifications ==========

    @Test
    void acquireLock_takeoverExpiredLockWithEdits_notifiesPreviousHolderEditAndPublishesAcquired()
    {
        // Arrange - editor's lock expired after they saved changes; owner takes over
        RecipeEditLock expired = expiredLock(editor);
        ReflectionTestUtils.setField(expired, "acquiredAt", OffsetDateTime.now().minusMinutes(10));
        ReflectionTestUtils.setField(ownedRecipe, "updatedAt", OffsetDateTime.now().minusMinutes(5));
        ownedRecipe.setTitle("Penne");
        sharedVault.setName("Family Dinners");

        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.of(ownedRecipe));
        when(recipeEditLockRepository.findById(1)).thenReturn(Optional.of(expired));
        when(userRepository.findById(1)).thenReturn(Optional.of(owner));
        when(recipeRepository.findById(1)).thenReturn(Optional.of(ownedRecipe));
        when(vaultRepository.findVaultByRecipeId(1)).thenReturn(Optional.of(sharedVault));
        when(notificationService.getDisplayName(2)).thenReturn("Editor");
        when(notificationService.getVaultParticipantIds(10, 2)).thenReturn(List.of(1));
        when(notificationService.getVaultParticipantIds(10, 1)).thenReturn(List.of(2));

        ArgumentCaptor<NotificationEvent> editCaptor = ArgumentCaptor.forClass(NotificationEvent.class);
        ArgumentCaptor<VaultLiveEvent> liveCaptor = ArgumentCaptor.forClass(VaultLiveEvent.class);

        // Act
        recipeEditLockService.acquireLock(1, 1);

        // Assert - RECIPE_EDITED is from previous holder
        verify(notificationService).publish(editCaptor.capture());
        NotificationEvent edit = editCaptor.getValue();
        assertEquals(NotificationType.RECIPE_EDITED, edit.type());
        assertEquals(2, edit.actorUserId());
        assertEquals(List.of(1), edit.recipientUserIds());
        assertEquals("Editor edited Penne in Family Dinners", edit.message());
        assertEquals(10, edit.refVaultId());
        assertEquals(1, edit.refRecipeId());

        // new lock - owner taken over
        verify(notificationService).publishLiveEvent(liveCaptor.capture());
        assertEquals(NotificationType.LOCK_ACQUIRED, liveCaptor.getValue().type());
        assertEquals(1, liveCaptor.getValue().actorUserId());
    }

    
    @Test
    void releaseLock_noEdits_onlyPublishesLockReleased()
    {
        // Arrange 
        // recipe wasn't saved
        RecipeEditLock existing = liveLock(owner);
        ReflectionTestUtils.setField(existing, "acquiredAt", OffsetDateTime.now().minusMinutes(1));
        ReflectionTestUtils.setField(ownedRecipe, "updatedAt", OffsetDateTime.now().minusMinutes(10));

        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.of(ownedRecipe));
        when(recipeEditLockRepository.findById(1)).thenReturn(Optional.of(existing));
        when(recipeRepository.findById(1)).thenReturn(Optional.of(ownedRecipe));
        when(vaultRepository.findVaultByRecipeId(1)).thenReturn(Optional.of(sharedVault));
        when(notificationService.getVaultParticipantIds(10, 1)).thenReturn(List.of(2));

        ArgumentCaptor<VaultLiveEvent> liveCaptor = ArgumentCaptor.forClass(VaultLiveEvent.class);

        // Act
        recipeEditLockService.releaseLock(1, 1);

        // Assert
        verify(notificationService, never()).publish(any());
        verify(notificationService).publishLiveEvent(liveCaptor.capture());
        assertEquals(NotificationType.LOCK_RELEASED, liveCaptor.getValue().type());
    }
}