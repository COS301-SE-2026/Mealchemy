// unit testing for adminService

package com.mealchemy.moderation;

//dtos
import com.mealchemy.moderation.dto.FlaggedRecipeResponse;
import com.mealchemy.moderation.dto.FlaggedRecipeDetailResponse;
import com.mealchemy.moderation.dto.FlagRequest;


//models
import com.mealchemy.moderation.model.FlaggedRecipe;
import com.mealchemy.moderation.model.FlagReasonOptions;
import com.mealchemy.recipe.model.Recipe;


//repositories
import com.mealchemy.moderation.repository.FlaggedRecipeRepository;
import com.mealchemy.moderation.repository.FlagReasonOptionsRepository;
import com.mealchemy.recipe.repository.RecipeRepository;

//enums
import com.mealchemy.shared.enums.FlagStatus;

//service
import com.mealchemy.moderation.service.FlagService;
import com.mealchemy.moderation.service.AdminService;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.ArgumentCaptor;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;
import java.util.Optional;
import java.time.OffsetDateTime;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class FlagServiceTest {
    // @Mock - create fake version of dependency
    @Mock private FlaggedRecipeRepository flaggedRecipeRepository;
    @Mock private FlagReasonOptionsRepository flagReasonOptionsRepository;
    @Mock private RecipeRepository recipeRepository;
    @Mock private AdminService adminService;

    // @InjectMocks creates the real PantryService and injects the mocks above into it - actually testing ShoppingListService
    @InjectMocks
    private FlagService flagService;

    private FlaggedRecipe existingFlag;
    private Recipe existingRecipe;
    private FlagReasonOptions reasonOption;
    private FlagRequest flagRequest;

    @BeforeEach
    void setUp() {
        // flagged recipe returned
        existingFlag = new FlaggedRecipe();
        existingFlag.setRecipeId(87);
        existingFlag.setFlaggedByUserId(4);
        existingFlag.setReason("SPAM_MISLEADING");
        existingFlag.setStatus(FlagStatus.PENDING);
        ReflectionTestUtils.setField(existingFlag, "flaggedId", 12);
        ReflectionTestUtils.setField(existingFlag, "flaggedAt", OffsetDateTime.parse("2026-09-17T23:00:00Z"));

        // recipe details
        existingRecipe = new Recipe();
        existingRecipe.setOwnerId(9);
        existingRecipe.setTitle("Penne Alla Vodka");
        existingRecipe.setDescription("Weeknight favourite");
        existingRecipe.setCuisineType("ITALIAN");
        existingRecipe.setPrepTimeMins(30);
        existingRecipe.setServingSize(4);
        existingRecipe.setPhotoUrl("https://photoUrl.com/penne.jpeg");
        existingRecipe.setIsCommunityPublished(true);
        ReflectionTestUtils.setField(existingRecipe, "recipeId", 87);

        // lookup value/label
        reasonOption = new FlagReasonOptions();
        reasonOption.setValue("SPAM_MISLEADING");
        reasonOption.setLabel("Spam / misleading");

        flagRequest = new FlagRequest("SPAM_MISLEADING");

        lenient().doNothing().when(adminService).requireAdmin(any());
    }

    // ========== Get Flags ==========

    @Test
    void getFlags_noStatus_defaultsToPending() {
        // Arrange
        when(flaggedRecipeRepository.findByStatus(FlagStatus.PENDING)).thenReturn(List.of(existingFlag));
        when(recipeRepository.findById(87)).thenReturn(Optional.of(existingRecipe));
        when(flagReasonOptionsRepository.findByValue("SPAM_MISLEADING")).thenReturn(Optional.of(reasonOption));
      
        // Act
        List<FlaggedRecipeResponse> responses = flagService.getFlags(null, 1);

        // Assert
        assertEquals(1, responses.size());
        assertEquals(12, responses.get(0).flaggedId());
        assertEquals("Spam / misleading", responses.get(0).reasonLabel());
        verify(flaggedRecipeRepository).findByStatus(FlagStatus.PENDING);
    }

    @Test
    void getFlags_statusProvided_useGivenStatus() {
        // Arrange
        existingFlag.setStatus(FlagStatus.REVIEWED);
        when(flaggedRecipeRepository.findByStatus(FlagStatus.REVIEWED)).thenReturn(List.of(existingFlag));
        when(recipeRepository.findById(87)).thenReturn(Optional.of(existingRecipe));
        when(flagReasonOptionsRepository.findByValue("SPAM_MISLEADING")).thenReturn(Optional.of(reasonOption));
      
        // Act
        List<FlaggedRecipeResponse> responses = flagService.getFlags(FlagStatus.REVIEWED, 1);

        // Assert
        assertEquals(1, responses.size());
        assertEquals(FlagStatus.REVIEWED, responses.get(0).status());
    }

    @Test
    void getFlags_notAdmin_throwsForbidden() {
        // Arrange
        doThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "User is not an Admin.")).when(adminService).requireAdmin(1);

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> flagService.getFlags(null, 1)
        );

        // Assert
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        verifyNoInteractions(flaggedRecipeRepository);
    }


    // ========== Get Flag Details ==========

    @Test
    void getFlagDetail_valid_returnsFlagDetailsWithNestedRecipe() {
        // Arrange
        when(flaggedRecipeRepository.findById(12)).thenReturn(Optional.of(existingFlag));
        when(recipeRepository.findById(87)).thenReturn(Optional.of(existingRecipe));
        when(flagReasonOptionsRepository.findByValue("SPAM_MISLEADING")).thenReturn(Optional.of(reasonOption));

        // Act 
        FlaggedRecipeDetailResponse response = flagService.getFlagDetail(12, 1);

        // Assert
        assertEquals(12, response.flaggedId());
        assertEquals("Spam / misleading", response.reasonLabel());
        assertNotNull(response.recipeResponse());
        assertEquals("Penne Alla Vodka", response.recipeResponse().title());
    }

    @Test
    void getFlagDetai_whenNotFound_throwsNotFound() {
        // Arrange
        when(flaggedRecipeRepository.findById(99)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> flagService.getFlagDetail(99, 1)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }


    // ========== Dismiss Flag ==========

    @Test
    void dismissFlag_valid_resolvesFlagAndSameReasonFlags() {
        // Arrange
        FlaggedRecipe siblingFlag = new FlaggedRecipe();
        siblingFlag.setRecipeId(87);
        siblingFlag.setFlaggedByUserId(5);
        siblingFlag.setReason("SPAM_MISLEADING");
        siblingFlag.setStatus(FlagStatus.PENDING);
        ReflectionTestUtils.setField(siblingFlag, "flaggedId", 13);

        when(flaggedRecipeRepository.findById(12)).thenReturn(Optional.of(existingFlag));
        when(flaggedRecipeRepository.findByRecipeIdAndReasonAndStatus(87, "SPAM_MISLEADING", FlagStatus.PENDING)).thenReturn(List.of(existingFlag, siblingFlag));
        when(recipeRepository.findById(87)).thenReturn(Optional.of(existingRecipe));
        when(flagReasonOptionsRepository.findByValue("SPAM_MISLEADING")).thenReturn(Optional.of(reasonOption));

        // Act 
        FlaggedRecipeResponse response = flagService.dismissFlag(12, 1);

        // Assert
        assertEquals(FlagStatus.REVIEWED, response.status());
        assertEquals(FlagStatus.REVIEWED, siblingFlag.getStatus());
        verify(flaggedRecipeRepository).saveAll(List.of(existingFlag, siblingFlag));
        // recipe stays published on dismiss
        assertTrue(existingRecipe.getIsCommunityPublished());
    }

    @Test
    void dismissFlag_notAdmin_throwsForbidden() {
        // Arrange
        doThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "User is not an Admin.")).when(adminService).requireAdmin(1);

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> flagService.dismissFlag(12, 1)
        );

        // Assert
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        verifyNoInteractions(flaggedRecipeRepository);
    }

    @Test
    void dismissFlag_whenNotFound_throwsNotFound() {
        // Arrange
        when(flaggedRecipeRepository.findById(99)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> flagService.dismissFlag(99, 1)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }


    // ========== Remove Flagged Recipe ==========

    @Test
    void removeFlaggedRecipe_valid_unpublishesRecipeAndResolvesFlagAndSameReasonFlags() {
        // Arrange
        FlaggedRecipe siblingFlag = new FlaggedRecipe();
        siblingFlag.setRecipeId(87);
        siblingFlag.setFlaggedByUserId(6);
        siblingFlag.setReason("SPAM_MISLEADING");
        siblingFlag.setStatus(FlagStatus.PENDING);
        ReflectionTestUtils.setField(siblingFlag, "flaggedId", 14);

        when(flaggedRecipeRepository.findById(12)).thenReturn(Optional.of(existingFlag));
        when(flaggedRecipeRepository.findByRecipeIdAndReasonAndStatus(87, "SPAM_MISLEADING", FlagStatus.PENDING)).thenReturn(List.of(existingFlag, siblingFlag));
        when(recipeRepository.findById(87)).thenReturn(Optional.of(existingRecipe));
        when(flagReasonOptionsRepository.findByValue("SPAM_MISLEADING")).thenReturn(Optional.of(reasonOption));

        // Act 
        FlaggedRecipeResponse response = flagService.removeFlaggedRecipe(12, 1);

        // Assert
        assertEquals(FlagStatus.REMOVED, response.status());
        assertEquals(FlagStatus.REMOVED, siblingFlag.getStatus());
        // recipe is removed from global vault
        assertFalse(existingRecipe.getIsCommunityPublished());
        verify(flaggedRecipeRepository).saveAll(List.of(existingFlag, siblingFlag));
    }

    @Test
    void removeFlaggedRecipe_notAdmin_throwsForbidden() {
        // Arrange
        doThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "User is not an Admin.")).when(adminService).requireAdmin(1);

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> flagService.removeFlaggedRecipe(12, 1)
        );

        // Assert
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
    }

    @Test
    void removeFlaggedRecipe_whenNotFound_throwsNotFound() {
        // Arrange
        when(flaggedRecipeRepository.findById(99)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> flagService.removeFlaggedRecipe(99, 1)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }


    // ========== Create Flag ==========

    @Test
    void createFlag_valid_savesAndReturnResponse() {
        // Arrange
        when(recipeRepository.findById(87)).thenReturn(Optional.of(existingRecipe));
        when(flagReasonOptionsRepository.existsByValue("SPAM_MISLEADING")).thenReturn(true);
        when(flaggedRecipeRepository.existsByRecipeIdAndUserIdAndStatus(87, 4, FlagStatus.PENDING)).thenReturn(false);
        when(flaggedRecipeRepository.save(any(FlaggedRecipe.class))).thenAnswer(inv -> {
            FlaggedRecipe saved = inv.getArgument(0);
            ReflectionTestUtils.setField(saved, "flaggedId", 20);
            ReflectionTestUtils.setField(saved, "flaggedAt", OffsetDateTime.parse("2026-09-18T10:00:00Z"));
            return saved;
        });
        when(flagReasonOptionsRepository.findByValue("SPAM_MISLEADING")).thenReturn(Optional.of(reasonOption));

        // Act 
        FlaggedRecipeResponse response = flagService.createFlag(87, flagRequest, 4);

        // Assert
        assertEquals(20, response.flaggedId());
        assertEquals(87, response.recipeId());
        assertEquals(4, response.flaggedByUserId());
        assertEquals(FlagStatus.PENDING, response.status());
        assertEquals("SPAM_MISLEADING", response.reasonValue());

        verify(flaggedRecipeRepository).save(any(FlaggedRecipe.class));
    }


    @Test
    void createFlag_recipeDoesNotExist_throwsNotFound() {
        // Arrange
        when(recipeRepository.findById(99)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> flagService.createFlag(99, flagRequest, 4)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void createFlag_inValidReasonValue_throwsBadRequest() {
        // Arrange
        FlagRequest badRequest = new FlagRequest("NOT_VALID");
        when(recipeRepository.findById(87)).thenReturn(Optional.of(existingRecipe));
        when(flagReasonOptionsRepository.existsByValue("NOT_VALID")).thenReturn(false);

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> flagService.createFlag(87, badRequest, 4)
        );

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
    }

    @Test
    void createFlag_alreadyHasPendingFlagFromUser_throwsConflict() {
        // Arrange
        when(recipeRepository.findById(87)).thenReturn(Optional.of(existingRecipe));
        when(flagReasonOptionsRepository.existsByValue("SPAM_MISLEADING")).thenReturn(true);
        when(flaggedRecipeRepository.existsByRecipeIdAndUserIdAndStatus(87, 4, FlagStatus.PENDING)).thenReturn(true);

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> flagService.createFlag(87, flagRequest, 4)
        );

        // Assert
        assertEquals(HttpStatus.CONFLICT, ex.getStatusCode());
        verify(flaggedRecipeRepository, never()).save(any());
    }
    
}