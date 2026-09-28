package com.mealchemy.mealprep.dto;

/* Import libraries */
import jakarta.validation.constraints.NotNull;

/* Import classes */

public record MealPlanRequest(
    @NotNull Integer vaultId
){}