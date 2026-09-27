package com.mealchemy.mealprep.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.*;
import java.util.stream.Collectors;

/* Import classes */
import com.mealchemy.engine.dto.SignalScoresResponse;
import com.mealchemy.engine.dto.SwipeUpdateDto;
import com.mealchemy.mealprep.model.MealPlanEntry;
import com.mealchemy.mealprep.model.MealPlanRecommendationSignal;
import com.mealchemy.mealprep.repository.MealPlanEntryRepository;
import com.mealchemy.mealprep.repository.MealPlanRecommendationSignalRepository;
import com.mealchemy.shared.enums.SwipeAction;
import com.mealchemy.swipes.service.LearningUpdateService;

@Service
public class MealPlanLearningSignalService {
    private final MealPlanRecommendationSignalRepository signalRepository;
    private final MealPlanEntryRepository mealPlanEntryRepository;
    private final LearningUpdateService learningUpdateService;

    public MealPlanLearningSignalService(MealPlanRecommendationSignalRepository signalRepository,
        MealPlanEntryRepository mealPlanEntryRepository, LearningUpdateService learningUpdateService)
    {
        this.signalRepository = signalRepository;
        this.mealPlanEntryRepository = mealPlanEntryRepository;
        this.learningUpdateService = learningUpdateService;
    }

    public void recordSkippedIfRecommended(Integer entryId)
    {
        Optional<MealPlanRecommendationSignal> maybeSignal = signalRepository.findByEntryId(entryId);
        if (maybeSignal.isEmpty())
        {
            return;
        }

        MealPlanRecommendationSignal signal = maybeSignal.get();
        if (signal.getProcessedAt() != null)
        {
            return;
        }

        MealPlanEntry entry = mealPlanEntryRepository.findById(entryId).orElse(null);
        if (entry == null)
        {
            return;
        }

        Integer userId = entry.getAddedBy();
        SwipeUpdateDto dto = toSwipeUpdateDto(signal, SwipeAction.SKIPPED);

        learningUpdateService.applyLearningUpdate(userId, List.of(dto));

        signal.setProcessedAt(OffsetDateTime.now());
        signalRepository.save(signal);
    }

    // Converts a captured signal row back into the shape LearningUpdateService already knows
    private SwipeUpdateDto toSwipeUpdateDto(MealPlanRecommendationSignal signal, SwipeAction action)
    {
        Map<String, Double> scores = signal.getSignalScores();
        SignalScoresResponse signalScores = SignalScoresResponse.from(
            scores.get("pantryMatch"),
            scores.get("cuisine"),
            scores.get("nutrition"),
            scores.get("freshness"),
            scores.get("novelty")
        );

        return new SwipeUpdateDto(
            signal.getRecipeId(),
            signal.getCuisine(),
            action,
            signalScores,
            null, 
            signal.getCapturedAt()
        );
    }
}