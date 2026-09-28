package com.mealchemy.mealprep.dto;

/* Import libraries */
import jakarta.validation.constraints.*;
import java.util.List;

/* Import classes */
import com.mealchemy.shared.enums.MealSlot;

public record DayRecommendationRequest(
    @NotNull MealSlot mealSlot,
    @NotNull @Min(1) Integer count,
    List<Integer> excludeRecipeIds
){}