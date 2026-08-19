package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import jakarta.validation.constraints.*;
import java.util.*;
import java.math.BigDecimal;

public record UserStateRequest(
    @NotNull Integer userId,
    @NotNull List<String> allergies,
    @NotNull List<String> dislikedIngredients,
    @NotNull List<String> dietaryRestrictions,
    @NotNull List<String> nutritionalGoals,
    @NotNull PreferenceWeightsRequest preferenceWeights,
    @NotNull Map<String, BigDecimal> cuisineAffinities,
    @NotNull List<PantryEntryRequest> pantry
)
{}