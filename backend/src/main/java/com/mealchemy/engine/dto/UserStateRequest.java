package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import jakarta.validation.constraints.*;
import java.util.*;
import java.math.BigDecimal;
import com.fasterxml.jackson.annotation.JsonProperty;

public record UserStateRequest(
    @JsonProperty("user_id") @NotNull Integer userId,
    @NotNull List<String> allergies,
    @JsonProperty("disliked_ingredients") @NotNull List<String> dislikedIngredients,
    @JsonProperty("dietary_restrictions") @NotNull List<String> dietaryRestrictions,
    @JsonProperty("nutritional_goals") @NotNull List<String> nutritionalGoals,
    @JsonProperty("preference_weights") @NotNull PreferenceWeightsRequest preferenceWeights,
    @JsonProperty("cuisine_affinities") @NotNull Map<String, BigDecimal> cuisineAffinities,
    @NotNull List<PantryEntryRequest> pantry,
    @JsonProperty("swipe_history") @NotNull List<SwipeHistoryEntryRequest> swipeHistory
)
{}