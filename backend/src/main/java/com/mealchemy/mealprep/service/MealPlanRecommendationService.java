package com.mealchemy.mealprep.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import java.time.LocalDate;
import java.util.*;

/* Import classes */
import com.mealchemy.engine.dto.EnrichedRecommendationResponse;
import com.mealchemy.engine.dto.PantryEntryRequest;
import com.mealchemy.engine.service.RecommendationService;
import com.mealchemy.mealprep.dto.DayRecommendationRequest;
import com.mealchemy.mealprep.dto.DayRecommendationResponse;
import com.mealchemy.mealprep.model.MealPlan;
import com.mealchemy.mealprep.repository.MealPlanRepository;
import com.mealchemy.preference.model.UserPreferences;
import com.mealchemy.preference.repository.UserPreferencesRepository;
import com.mealchemy.shared.enums.VaultType;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.repository.VaultRepository;

@Service
public class MealPlanRecommendationService {
    private final RecommendationService recommendationService;
    private final PantryProjectionService pantryProjectionService;
    private final UserPreferencesRepository userPreferencesRepository;
    private final MealPlanRepository mealPlanRepository;
    private final VaultRepository vaultRepository;

    public MealPlanRecommendationService(RecommendationService recommendationService,
        PantryProjectionService pantryProjectionService, UserPreferencesRepository userPreferencesRepository,
        MealPlanRepository mealPlanRepository, VaultRepository vaultRepository)
    {
        this.recommendationService = recommendationService;
        this.pantryProjectionService = pantryProjectionService;
        this.userPreferencesRepository = userPreferencesRepository;
        this.mealPlanRepository = mealPlanRepository;
        this.vaultRepository = vaultRepository;
    }

    List<String> mapGoalsToRequiredTags(Integer userId)
    {
        UserPreferences preferences = userPreferencesRepository.findByUserId(userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "User preferences not initialized."));

        List<String> goals = preferences.getNutritionalGoals();
        if (goals == null || goals.isEmpty())
        {
            return null;
        }

        List<String> requiredTags = new ArrayList<>();
        if (goals.stream().anyMatch(goal -> "MEAL_PREP".equalsIgnoreCase(goal)))
        {
            requiredTags.add("MEAL_PREP");
        }

        return requiredTags.isEmpty() ? null : requiredTags;
    }
}