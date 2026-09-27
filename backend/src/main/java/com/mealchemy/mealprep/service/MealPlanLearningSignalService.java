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
}