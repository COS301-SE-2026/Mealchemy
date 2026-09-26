package com.mealchemy.backend.dto.mealplan;

/* Import libraries */

/* Import classes */

public record MealPlanResponse(
    Long planId,
    Long vaultId,
    Long createdBy
){}