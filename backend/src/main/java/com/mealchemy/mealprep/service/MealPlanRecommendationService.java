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

    public DayRecommendationResponse getDayRecommendations(Integer userId, Integer planId, LocalDate date, DayRecommendationRequest request)
    {
        assertPrivateVaultPlan(planId);

        if (request.count() != null && request.count() <= 0)
        {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "count must be greater than 0.");
        }

        List<Integer> excludeRecipeIds = request.excludeRecipeIds() != null ? request.excludeRecipeIds() : Collections.emptyList();

        List<PantryEntryRequest> projectedPantry = pantryProjectionService.buildProjectedPantry(userId, planId, date);
        List<String> requiredTags = mapGoalsToRequiredTags(userId);

        EnrichedRecommendationResponse response = recommendationService.getRecommendations(
            userId, request.count(), excludeRecipeIds, null, projectedPantry, requiredTags
        );

        return new DayRecommendationResponse(date, request.mealSlot(), response.recommendations());
    }

    void assertPrivateVaultPlan(Integer planId)
    {
        MealPlan plan = mealPlanRepository.findById(planId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Meal plan not found."));

        Vault vault = vaultRepository.findById(plan.getVaultId())
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Vault not found for meal plan."));

        if (vault.getVaultType() != VaultType.PRIVATE)
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                "Recommendation-based meal planning is only available for private vaults.");
        }
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