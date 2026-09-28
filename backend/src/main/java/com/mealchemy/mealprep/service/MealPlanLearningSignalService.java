package com.mealchemy.mealprep.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.*;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

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
    private static final Logger log = LoggerFactory.getLogger(MealPlanLearningSignalService.class);

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

    public void processDueLikedSignals()
    {
        List<MealPlanRecommendationSignal> unprocessed = signalRepository.findByProcessedAtIsNull();
        if (unprocessed.isEmpty())
        {
            return;
        }

        LocalDate today = LocalDate.now();

        List<Integer> entryIds = unprocessed.stream().map(MealPlanRecommendationSignal::getEntryId).toList();
        Map<Integer, MealPlanEntry> entryById = mealPlanEntryRepository.findAllById(entryIds).stream()
            .collect(Collectors.toMap(MealPlanEntry::getEntryId, e -> e));

        Map<Integer, List<MealPlanRecommendationSignal>> dueByUserId = unprocessed.stream()
            .filter(signal -> {
                MealPlanEntry entry = entryById.get(signal.getEntryId());
                return entry != null && !entry.getEntryDate().isAfter(today);
            })
            .collect(Collectors.groupingBy(signal -> entryById.get(signal.getEntryId()).getAddedBy()));

        List<MealPlanRecommendationSignal> successfullyProcessed = new ArrayList<>();

        dueByUserId.forEach((userId, signals) -> {
            List<SwipeUpdateDto> dtos = signals.stream()
                .map(signal -> toSwipeUpdateDto(signal, SwipeAction.LIKED))
                .toList();

            try
            {
                learningUpdateService.applyLearningUpdate(userId, dtos);

                OffsetDateTime now = OffsetDateTime.now();
                signals.forEach(signal -> signal.setProcessedAt(now));
                successfullyProcessed.addAll(signals);
            }
            catch (Exception ex)
            {
                log.warn("Learning update failed for user {} during meal-plan LIKED sweep, will retry on next sweep", userId, ex);
            }
        });

        if (!successfullyProcessed.isEmpty())
        {
            signalRepository.saveAll(successfullyProcessed);
        }
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