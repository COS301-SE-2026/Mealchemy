package com.mealchemy.mealprep.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import java.time.*;
import java.util.*;

/* Import classes */
import com.mealchemy.engine.dto.EnrichedRecommendationItem;
import com.mealchemy.engine.dto.EnrichedRecommendationResponse;
import com.mealchemy.engine.dto.PantryEntryRequest;
import com.mealchemy.engine.dto.SignalScoresResponse;
import com.mealchemy.engine.service.RecommendationService;
import com.mealchemy.mealprep.dto.DayRecommendationRequest;
import com.mealchemy.mealprep.dto.DayRecommendationResponse;
import com.mealchemy.mealprep.dto.GenerateRecommendationsRequest;
import com.mealchemy.mealprep.dto.GenerateRecommendationsResponse;
import com.mealchemy.mealprep.dto.MealPlanEntryResponse;
import com.mealchemy.mealprep.exception.InvalidMealSlotTimeException;
import com.mealchemy.mealprep.model.MealPlan;
import com.mealchemy.mealprep.model.MealPlanEntry;
import com.mealchemy.mealprep.model.MealPlanRecommendationSignal;
import com.mealchemy.mealprep.repository.MealPlanEntryRepository;
import com.mealchemy.mealprep.repository.MealPlanRecommendationSignalRepository;
import com.mealchemy.mealprep.repository.MealPlanRepository;
import com.mealchemy.preference.model.UserPreferences;
import com.mealchemy.preference.repository.UserPreferencesRepository;
import com.mealchemy.shared.enums.MealPlanEntrySource;
import com.mealchemy.shared.enums.MealSlot;
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
    private final MealPlanService mealPlanService;
    private final MealPlanEntryRepository mealPlanEntryRepository;
    private final MealPlanRecommendationSignalRepository signalRepository;

    public MealPlanRecommendationService(RecommendationService recommendationService,
        PantryProjectionService pantryProjectionService, UserPreferencesRepository userPreferencesRepository,
        MealPlanRepository mealPlanRepository, VaultRepository vaultRepository, MealPlanService mealPlanService,
        MealPlanEntryRepository mealPlanEntryRepository, MealPlanRecommendationSignalRepository signalRepository)
    {
        this.recommendationService = recommendationService;
        this.pantryProjectionService = pantryProjectionService;
        this.userPreferencesRepository = userPreferencesRepository;
        this.mealPlanRepository = mealPlanRepository;
        this.vaultRepository = vaultRepository;
        this.mealPlanService = mealPlanService;
        this.mealPlanEntryRepository = mealPlanEntryRepository;
        this.signalRepository = signalRepository;
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

    public GenerateRecommendationsResponse generate(Integer userId, Integer planId, GenerateRecommendationsRequest request)
    {
        assertPersonalVaultPlan(planId);

        if (request.startDate().isAfter(request.endDate()))
        {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "startDate must not be after endDate.");
        }

        // Validate every mealSlot/slotTime pair up front
        for (MealSlot mealSlot : request.mealSlots())
        {
            LocalTime slotTime = request.slotTimes().get(mealSlot);
            if (slotTime == null)
            {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No slotTime provided for meal slot " + mealSlot + ".");
            }
            if (!mealSlot.allows(slotTime))
            {
                throw new InvalidMealSlotTimeException("mealTime " + slotTime + " is outside the valid range for " + mealSlot + ".");
            }
        }

        List<String> requiredTags = mapGoalsToRequiredTags(userId);
        Integer seed = request.seed() != null ? request.seed().intValue() : null;

        List<MealPlanEntryResponse> generatedEntries = new ArrayList<>();
        List<GenerateRecommendationsResponse.SkippedDate> skippedDates = new ArrayList<>();

        for (LocalDate date = request.startDate(); !date.isAfter(request.endDate()); date = date.plusDays(1))
        {
            // Projected once per date, reused across every meal slot on that date
            List<PantryEntryRequest> projectedPantry = pantryProjectionService.buildProjectedPantry(userId, planId, date);

            for (MealSlot mealSlot : request.mealSlots())
            {
                LocalTime slotTime = request.slotTimes().get(mealSlot);

                Optional<MealPlanEntry> existing = mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateAndMealSlot(planId, date, mealSlot);

                if (existing.isPresent())
                {
                    MealPlanEntry existingEntry = existing.get();

                    if (existingEntry.getSource() == MealPlanEntrySource.MANUAL)
                    {
                        skippedDates.add(new GenerateRecommendationsResponse.SkippedDate(date, mealSlot,
                            GenerateRecommendationsResponse.SkippedDate.Reason.MANUAL_ENTRY_PRESENT));
                        continue;
                    }

                    // existingEntry.getSource() == RECOMMENDED
                    if (!request.overwriteRecommended())
                    {
                        continue;
                    }

                    // Remove signal row before overwriting
                    signalRepository.findByEntryId(existingEntry.getEntryId()).ifPresent(signalRepository::delete);
                }

                EnrichedRecommendationResponse response = recommendationService.getRecommendations(
                    userId, 1, Collections.emptyList(), seed, projectedPantry, requiredTags
                );

                if (response.recommendations() == null || response.recommendations().isEmpty())
                {
                    skippedDates.add(new GenerateRecommendationsResponse.SkippedDate(date, mealSlot,
                        GenerateRecommendationsResponse.SkippedDate.Reason.NO_CANDIDATES_AFTER_PROJECTION));
                    continue;
                }

                EnrichedRecommendationItem pick = response.recommendations().get(0);

                MealPlanEntryResponse entryResponse = mealPlanService.addEntry(
                    planId, userId, date, slotTime, mealSlot, null, null, pick.recipeId(), MealPlanEntrySource.RECOMMENDED, true
                );

                persistSignal(entryResponse.entryId(), pick);
                generatedEntries.add(entryResponse);
            }
        }

        return new GenerateRecommendationsResponse(generatedEntries, skippedDates);
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