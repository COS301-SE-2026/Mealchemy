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

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import jakarta.persistence.EntityManager;

/* Import classes */
import com.mealchemy.vault.model.RecipeEditLock;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.repository.RecipeEditLockRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.vault.dto.RecipeLockResponse;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.auth.model.User;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.shared.enums.VaultMemberRole;


@ExtendWith(MockitoExtension.class)
public class RecipeEditLockServiceTest {
    // @Mock - create fake version of dependency
    @Mock private RecipeEditLockRepository recipeEditLockRepository;
    @Mock private RecipeRepository recipeRepository;
    @Mock private VaultMemberRepository vaultMemberRepository;
    @Mock private UserRepository userRepository; 
    @Mock private EntityManager entityManager;

    @InjectMocks
    private RecipeEditLockService recipeEditLockService;

    private Recipe ownedRecipe; // can be edited 
    private User owner;
    private User editor;
    private VaultMember editorMembership;

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
        when(vaultMemberRepository.findVaultMembershipForRecipe(1, 2)).thenReturn(Optional.of(editorMembership));
        when(recipeEditLockRepository.findById(1)).thenReturn(Optional.of(liveLock(editor)));

        // Act and Assert
        assertTrue(recipeEditLockService.canEditRecipe(1, 2));
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
        when(vaultMemberRepository.findVaultMembershipForRecipe(1, 3)).thenReturn(Optional.of(viewerMembership));

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> recipeEditLockService.canEditRecipe(1, 3)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }
}