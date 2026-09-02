package com.mealchemy.swipes.service;

/* Import libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/* Import classes */
import com.mealchemy.preference.model.UserPreferenceWeights;
import com.mealchemy.preference.model.UserCuisineAffinities;
import com.mealchemy.preference.repository.UserPreferenceWeightsRepository;
import com.mealchemy.preference.repository.UserCuisineAffinitiesRepository;
import com.mealchemy.engine.client.EngineClient;
import com.mealchemy.engine.dto.PreferenceWeightsRequest;
import com.mealchemy.engine.dto.LearningUpdateResponse;
import com.mealchemy.engine.dto.LearningUpdateRequest;
import com.mealchemy.engine.dto.LearningUpdateResult;
import com.mealchemy.engine.dto.SwipeUpdateDto;
import com.mealchemy.engine.dto.SignalScoresResponse;
import com.mealchemy.swipes.model.Swipe;
import com.mealchemy.swipes.repository.SwipeRepository;
import com.mealchemy.shared.enums.SwipeAction;

@ExtendWith(MockitoExtension.class)
public class LearningUpdateServiceTest {

    private static final Integer USER_ID = 1;

    @Mock private UserPreferenceWeightsRepository userPreferenceWeightsRepository;
    @Mock private UserCuisineAffinitiesRepository userCuisineAffinitiesRepository;
    @Mock private EngineClient engineClient;
    @Mock private SwipeRepository swipeRepository;

    @InjectMocks
    private LearningUpdateService learningUpdateService;

    private UserPreferenceWeights currentWeights;
    private LearningUpdateResponse engineResponse;

    @BeforeEach
    void setUp()
    {
        currentWeights = new UserPreferenceWeights();
        currentWeights.setUserId(USER_ID);
        currentWeights.setPantryMatch(new BigDecimal("0.40"));
        currentWeights.setCuisine(new BigDecimal("0.25"));
        currentWeights.setNutrition(new BigDecimal("0.15"));
        currentWeights.setFreshness(new BigDecimal("0.10"));
        currentWeights.setNovelty(new BigDecimal("0.10"));
        currentWeights.setStateVersion(3);

        PreferenceWeightsRequest updatedWeights = new PreferenceWeightsRequest(
            new BigDecimal("0.42"), new BigDecimal("0.23"), new BigDecimal("0.15"),
            new BigDecimal("0.10"), new BigDecimal("0.10")
        );
        engineResponse = new LearningUpdateResponse(updatedWeights, Map.of("ITALIAN", new BigDecimal(0.75)), 3);

        lenient().when(userPreferenceWeightsRepository.findByUserId(USER_ID)).thenReturn(Optional.of(currentWeights));
        lenient().when(userCuisineAffinitiesRepository.findAllByUserId(USER_ID)).thenReturn(List.of());
        lenient().when(engineClient.updateLearning(any(LearningUpdateRequest.class))).thenReturn(engineResponse);
        lenient().when(userCuisineAffinitiesRepository.findByUserIdAndCuisineValue(any(), any())).thenReturn(Optional.empty());
    }

    // ========== applyLearningUpdate ==========

    @Test
    void applyLearningUpdate_happyPath_persistsWeightsAndAffinities()
    {
        // Arrange
        when(userPreferenceWeightsRepository.updateWeightsIfVersionMatches(
            eq(USER_ID), any(), any(), any(), any(), any(), eq(3))).thenReturn(1);

        // Act
        LearningUpdateResult result = learningUpdateService.applyLearningUpdate(USER_ID, List.of());

        // Assert
        assertEquals(4, result.stateVersion());
        verify(userCuisineAffinitiesRepository).save(any(UserCuisineAffinities.class));
    }

    @Test
    void applyLearningUpdate_whenVersionMismatch_throwsConflict()
    {
        // Arrange
        when(userPreferenceWeightsRepository.updateWeightsIfVersionMatches(
            eq(USER_ID), any(), any(), any(), any(), any(), eq(3))).thenReturn(0);

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> learningUpdateService.applyLearningUpdate(USER_ID, List.of())
        );

        // Assert
        assertEquals(HttpStatus.CONFLICT, ex.getStatusCode());
        verify(userCuisineAffinitiesRepository, never()).save(any());
    }

    @Test
    void applyLearningUpdate_whenWeightsNotInitialized_throwsInternalServerError()
    {
        // Arrange
        when(userPreferenceWeightsRepository.findByUserId(USER_ID)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> learningUpdateService.applyLearningUpdate(USER_ID, List.of())
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    // ========== flushSwipes ==========

    @Test
    void flushSwipes_noUnflushedSwipes_doesNothing()
    {
        // Arrange
        when(swipeRepository.findByUserIdAndFlushedFalse(USER_ID)).thenReturn(List.of());

        // Act
        learningUpdateService.flushSwipes(USER_ID);

        // Assert
        verify(engineClient, never()).updateLearning(any());
        verify(swipeRepository, never()).saveAll(any());
    }

    @Test
    void flushSwipes_success_marksAllUnflushedSwipesAsFlushed()
    {
        // Arrange
        Swipe swipe1 = new Swipe();
        swipe1.setUserId(USER_ID);
        swipe1.setRecipeId(100);
        swipe1.setCuisineValue("ITALIAN");
        swipe1.setAction(SwipeAction.LIKED);
        swipe1.setWeightsSnapshot(new SignalScoresResponse(0.9, 0.8, 0.5, 0.3, 1.0));
        swipe1.setFlushed(false);

        Swipe swipe2 = new Swipe();
        swipe2.setUserId(USER_ID);
        swipe2.setRecipeId(101);
        swipe2.setCuisineValue("MEXICAN");
        swipe2.setAction(SwipeAction.DISLIKED);
        swipe2.setWeightsSnapshot(new SignalScoresResponse(0.2, 0.3, 0.5, 0.5, 0.4));
        swipe2.setFlushed(false);

        when(swipeRepository.findByUserIdAndFlushedFalse(USER_ID)).thenReturn(List.of(swipe1, swipe2));
        when(userPreferenceWeightsRepository.updateWeightsIfVersionMatches(
            eq(USER_ID), any(), any(), any(), any(), any(), eq(3))).thenReturn(1);

        // Act
        learningUpdateService.flushSwipes(USER_ID);

        // Assert
        ArgumentCaptor<List<Swipe>> captor = ArgumentCaptor.forClass(List.class);
        verify(swipeRepository).saveAll(captor.capture());
        assertTrue(captor.getValue().stream().allMatch(Swipe::getFlushed));

        ArgumentCaptor<LearningUpdateRequest> requestCaptor = ArgumentCaptor.forClass(LearningUpdateRequest.class);
        verify(engineClient).updateLearning(requestCaptor.capture());
        List<SwipeUpdateDto> sentSwipes = requestCaptor.getValue().swipes();
        assertEquals(2, sentSwipes.size());
        assertEquals(100, sentSwipes.get(0).recipeId());
        assertEquals("ITALIAN", sentSwipes.get(0).cuisine());
    }

    @Test
    void flushSwipes_whenUpdateFails_swipesAreNotMarkedFlushed()
    {
        // Arrange
        Swipe swipe = new Swipe();
        swipe.setUserId(USER_ID);
        swipe.setRecipeId(100);
        swipe.setCuisineValue("ITALIAN");
        swipe.setAction(SwipeAction.LIKED);
        swipe.setWeightsSnapshot(new SignalScoresResponse(0.9, 0.8, 0.5, 0.3, 1.0));
        swipe.setFlushed(false);

        when(swipeRepository.findByUserIdAndFlushedFalse(USER_ID)).thenReturn(List.of(swipe));
        when(userPreferenceWeightsRepository.updateWeightsIfVersionMatches(
            eq(USER_ID), any(), any(), any(), any(), any(), eq(3))).thenReturn(0);

        // Act & Assert
        assertThrows(ResponseStatusException.class, () -> learningUpdateService.flushSwipes(USER_ID));
        verify(swipeRepository, never()).saveAll(any());
    }
}