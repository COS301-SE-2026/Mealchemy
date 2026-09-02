package com.mealchemy.swipes.service;

/* Import libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/* Import classes */
import com.mealchemy.swipes.model.Swipe;
import com.mealchemy.swipes.repository.SwipeRepository;
import com.mealchemy.shared.enums.SwipeAction;
import com.mealchemy.engine.dto.SignalScoresResponse;

@ExtendWith(MockitoExtension.class)
public class SwipeServiceTest {

    private static final Integer USER_ID = 1;

    @Mock private SwipeRepository swipeRepository;
    @Mock private LearningUpdateService learningUpdateService;

    @InjectMocks
    private SwipeService swipeService;

    private SignalScoresResponse signalScores;

    @BeforeEach
    void setUp()
    {
        signalScores = new SignalScoresResponse(0.9, 0.8, 0.5, 0.3, 1.0);
        lenient().when(swipeRepository.save(any(Swipe.class))).thenAnswer(invocation -> invocation.getArgument(0));
    }

    @Test
    void recordSwipe_savesNewSwipeWithFlushedFalse()
    {
        // Arrange
        when(swipeRepository.countByUserIdAndFlushedFalse(USER_ID)).thenReturn(3L);

        // Act
        swipeService.recordSwipe(USER_ID, 100, "ITALIAN", SwipeAction.LIKED, signalScores);

        // Assert
        ArgumentCaptor<Swipe> captor = ArgumentCaptor.forClass(Swipe.class);
        verify(swipeRepository).save(captor.capture());
        Swipe saved = captor.getValue();

        assertEquals(USER_ID, saved.getUserId());
        assertEquals(100, saved.getRecipeId());
        assertEquals("ITALIAN", saved.getCuisineValue());
        assertEquals(SwipeAction.LIKED, saved.getAction());
        assertEquals(signalScores, saved.getWeightsSnapshot());
        assertFalse(saved.getFlushed());
    }

    @Test
    void recordSwipe_belowBatchThreshold_doesNotTriggerFlush()
    {
        // Arrange
        when(swipeRepository.countByUserIdAndFlushedFalse(USER_ID)).thenReturn(9L);

        // Act
        swipeService.recordSwipe(USER_ID, 100, "ITALIAN", SwipeAction.LIKED, signalScores);

        // Assert
        verify(learningUpdateService, never()).flushSwipes(any());
    }

    @Test
    void recordSwipe_reachesBatchThreshold_triggersFlush()
    {
        // Arrange
        when(swipeRepository.countByUserIdAndFlushedFalse(USER_ID)).thenReturn(10L);

        // Act
        swipeService.recordSwipe(USER_ID, 100, "ITALIAN", SwipeAction.LIKED, signalScores);

        // Assert
        verify(learningUpdateService).flushSwipes(USER_ID);
    }

    @Test
    void recordSwipe_whenFlushFails_swipeIsStillReturnedWithoutPropagatingException()
    {
        // Arrange
        when(swipeRepository.countByUserIdAndFlushedFalse(USER_ID)).thenReturn(10L);
        doThrow(new RuntimeException("engine unreachable")).when(learningUpdateService).flushSwipes(USER_ID);

        // Act
        Swipe result = assertDoesNotThrow(
            () -> swipeService.recordSwipe(USER_ID, 100, "ITALIAN", SwipeAction.LIKED, signalScores)
        );

        // Assert
        assertNotNull(result);
        assertEquals(100, result.getRecipeId());
    }
}