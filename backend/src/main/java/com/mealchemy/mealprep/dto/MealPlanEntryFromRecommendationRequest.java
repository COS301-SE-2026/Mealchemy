package com.mealchemy.mealprep.dto;

/* Import libraries */
import jakarta.validation.constraints.*;
import java.time.*;

/* Import classes */
import com.mealchemy.engine.dto.SignalScoresResponse;
import com.mealchemy.shared.enums.MealSlot;

public record MealPlanEntryFromRecommendationRequest(
    @NotNull Integer recipeId,
    @NotNull LocalDate entryDate,
    @NotNull MealSlot mealSlot,
    @NotNull LocalTime mealTime,
    @Size(max = 200) String title,
    @Size(max = 500) String note,
    @NotNull String cuisineType,
    @NotNull SignalScoresResponse scoreBreakdown
){}