package com.mealchemy.mealprep.service;

import com.mealchemy.engine.dto.SwipeUpdateDto;
import com.mealchemy.mealprep.model.MealPlanEntry;
import com.mealchemy.mealprep.model.MealPlanRecommendationSignal;
import com.mealchemy.mealprep.repository.MealPlanEntryRepository;
import com.mealchemy.mealprep.repository.MealPlanRecommendationSignalRepository;
import com.mealchemy.shared.enums.SwipeAction;
import com.mealchemy.swipes.service.LearningUpdateService;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class MealPlanLearningSignalServiceTest {

    private static final Integer ENTRY_ID = 55;
    private static final Integer USER_ID = 1;
    private static final Integer RECIPE_ID = 100;

    @Mock private MealPlanRecommendationSignalRepository signalRepository;
    @Mock private MealPlanEntryRepository mealPlanEntryRepository;
    @Mock private LearningUpdateService learningUpdateService;

    @InjectMocks
    private MealPlanLearningSignalService mealPlanLearningSignalService;

    private MealPlanRecommendationSignal signalFor(Integer entryId, LocalDate capturedDate) {
        MealPlanRecommendationSignal signal = new MealPlanRecommendationSignal();
        signal.setEntryId(entryId);
        signal.setRecipeId(RECIPE_ID);
        signal.setCuisine("ITALIAN");
        signal.setSignalScores(Map.of(
            "pantryMatch", 0.5, "cuisine", 0.5, "nutrition", 0.5, "freshness", 0.5, "novelty", 0.5
        ));
        ReflectionTestUtils.setField(signal, "capturedAt", capturedDate.atStartOfDay().atOffset(java.time.ZoneOffset.UTC));
        return signal;
    }

    private MealPlanEntry entry(Integer entryId, Integer addedBy, LocalDate entryDate) {
        MealPlanEntry entry = new MealPlanEntry();
        ReflectionTestUtils.setField(entry, "entryId", entryId);
        entry.setAddedBy(addedBy);
        entry.setEntryDate(entryDate);
        return entry;
    }

    // ========== recordSkippedIfRecommended ==========

    @Test
    void recordSkippedIfRecommended_noSignalRow_noOp() {
        // Arrange
        when(signalRepository.findByEntryId(ENTRY_ID)).thenReturn(Optional.empty());

        // Act
        mealPlanLearningSignalService.recordSkippedIfRecommended(ENTRY_ID);

        // Assert
        verifyNoInteractions(learningUpdateService);
        verify(signalRepository, never()).save(any());
    }

    @Test
    void recordSkippedIfRecommended_alreadyProcessed_noOp() {
        // Arrange
        MealPlanRecommendationSignal signal = signalFor(ENTRY_ID, LocalDate.now());
        signal.setProcessedAt(OffsetDateTime.now());
        when(signalRepository.findByEntryId(ENTRY_ID)).thenReturn(Optional.of(signal));

        // Act
        mealPlanLearningSignalService.recordSkippedIfRecommended(ENTRY_ID);

        // Assert
        verifyNoInteractions(learningUpdateService);
        verify(signalRepository, never()).save(any());
    }

    @Test
    void recordSkippedIfRecommended_entryMissing_noOp() {
        // Arrange
        MealPlanRecommendationSignal signal = signalFor(ENTRY_ID, LocalDate.now());
        when(signalRepository.findByEntryId(ENTRY_ID)).thenReturn(Optional.of(signal));
        when(mealPlanEntryRepository.findById(ENTRY_ID)).thenReturn(Optional.empty());

        // Act
        mealPlanLearningSignalService.recordSkippedIfRecommended(ENTRY_ID);

        // Assert
        verifyNoInteractions(learningUpdateService);
        verify(signalRepository, never()).save(any());
    }

    @Test
    void recordSkippedIfRecommended_happyPath_postsSkippedAndMarksProcessed() {
        // Arrange
        MealPlanRecommendationSignal signal = signalFor(ENTRY_ID, LocalDate.now());
        when(signalRepository.findByEntryId(ENTRY_ID)).thenReturn(Optional.of(signal));
        when(mealPlanEntryRepository.findById(ENTRY_ID)).thenReturn(Optional.of(entry(ENTRY_ID, USER_ID, LocalDate.now())));

        ArgumentCaptor<List<SwipeUpdateDto>> captor = ArgumentCaptor.forClass(List.class);

        // Act
        mealPlanLearningSignalService.recordSkippedIfRecommended(ENTRY_ID);

        // Assert
        verify(learningUpdateService).applyLearningUpdate(eq(USER_ID), captor.capture());
        assertEquals(1, captor.getValue().size());
        assertEquals(SwipeAction.SKIPPED, captor.getValue().get(0).action());
        assertEquals(RECIPE_ID, captor.getValue().get(0).recipeId());

        assertNotNull(signal.getProcessedAt());
        verify(signalRepository).save(signal);
    }

    // ========== processDueLikedSignals ==========

    @Test
    void processDueLikedSignals_noUnprocessedSignals_doesNothing() {
        // Arrange
        when(signalRepository.findByProcessedAtIsNull()).thenReturn(List.of());

        // Act
        mealPlanLearningSignalService.processDueLikedSignals();

        // Assert
        verifyNoInteractions(learningUpdateService, mealPlanEntryRepository);
        verify(signalRepository, never()).saveAll(any());
    }

    @Test
    void processDueLikedSignals_entryDateInFuture_notIncluded() {
        // Arrange
        MealPlanRecommendationSignal signal = signalFor(ENTRY_ID, LocalDate.now());
        MealPlanEntry futureEntry = entry(ENTRY_ID, USER_ID, LocalDate.now().plusDays(5));

        when(signalRepository.findByProcessedAtIsNull()).thenReturn(List.of(signal));
        when(mealPlanEntryRepository.findAllById(List.of(ENTRY_ID))).thenReturn(List.of(futureEntry));
        
        // Act
        mealPlanLearningSignalService.processDueLikedSignals();

        // Assert
        verifyNoInteractions(learningUpdateService);
        verify(signalRepository, never()).saveAll(any());
    }

    @Test
    void processDueLikedSignals_dueSignal_postsLikedAndMarksProcessed() {
        // Arrange
        MealPlanRecommendationSignal signal = signalFor(ENTRY_ID, LocalDate.now());
        MealPlanEntry dueEntry = entry(ENTRY_ID, USER_ID, LocalDate.now().minusDays(1));

        when(signalRepository.findByProcessedAtIsNull()).thenReturn(List.of(signal));
        when(mealPlanEntryRepository.findAllById(List.of(ENTRY_ID))).thenReturn(List.of(dueEntry));

        ArgumentCaptor<List<SwipeUpdateDto>> captor = ArgumentCaptor.forClass(List.class);

        // Act
        mealPlanLearningSignalService.processDueLikedSignals();

        // Assert
        verify(learningUpdateService).applyLearningUpdate(eq(USER_ID), captor.capture());
        assertEquals(SwipeAction.LIKED, captor.getValue().get(0).action());
        assertNotNull(signal.getProcessedAt());
        verify(signalRepository).saveAll(List.of(signal));
    }

    @Test
    void processDueLikedSignals_groupsByUser_separateCallsPerUser() {
        // Arrange
        Integer entryId2 = 56;
        Integer userId2 = 2;

        MealPlanRecommendationSignal signal1 = signalFor(ENTRY_ID, LocalDate.now());
        MealPlanRecommendationSignal signal2 = signalFor(entryId2, LocalDate.now());

        MealPlanEntry entry1 = entry(ENTRY_ID, USER_ID, LocalDate.now().minusDays(1));
        MealPlanEntry entry2 = entry(entryId2, userId2, LocalDate.now().minusDays(1));

        when(signalRepository.findByProcessedAtIsNull()).thenReturn(List.of(signal1, signal2));
        when(mealPlanEntryRepository.findAllById(List.of(ENTRY_ID, entryId2))).thenReturn(List.of(entry1, entry2));

        // Act
        mealPlanLearningSignalService.processDueLikedSignals();

        // Assert
        verify(learningUpdateService).applyLearningUpdate(eq(USER_ID), anyList());
        verify(learningUpdateService).applyLearningUpdate(eq(userId2), anyList());
    }

    @Test
    void processDueLikedSignals_oneUserFails_otherUserStillProcessed() {
        // Arrange
        Integer entryId2 = 56;
        Integer userId2 = 2;

        MealPlanRecommendationSignal signal1 = signalFor(ENTRY_ID, LocalDate.now());
        MealPlanRecommendationSignal signal2 = signalFor(entryId2, LocalDate.now());

        MealPlanEntry entry1 = entry(ENTRY_ID, USER_ID, LocalDate.now().minusDays(1));
        MealPlanEntry entry2 = entry(entryId2, userId2, LocalDate.now().minusDays(1));

        when(signalRepository.findByProcessedAtIsNull()).thenReturn(List.of(signal1, signal2));
        when(mealPlanEntryRepository.findAllById(List.of(ENTRY_ID, entryId2))).thenReturn(List.of(entry1, entry2));

        doThrow(new RuntimeException("state_version conflict")).when(learningUpdateService).applyLearningUpdate(eq(USER_ID), anyList());

        // Act
        mealPlanLearningSignalService.processDueLikedSignals();

        // Assert
        assertNull(signal1.getProcessedAt());
        assertNotNull(signal2.getProcessedAt());
        verify(signalRepository).saveAll(List.of(signal2));
    }
}