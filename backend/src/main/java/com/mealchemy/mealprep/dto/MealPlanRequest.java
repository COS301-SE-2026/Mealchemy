package com.mealchemy.mealprep.dto.mealplan;

/* Import libraries */
import jakarta.validation.constraints.NotNull;

/* Import classes */

public record MealPlanRequest(
    @NotNull Long vaultId
){}