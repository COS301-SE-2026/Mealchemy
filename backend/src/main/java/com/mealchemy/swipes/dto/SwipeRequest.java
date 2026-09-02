package com.mealchemy.swipes.dto;

/* Import libraries */
import com.mealchemy.shared.enums.SwipeAction;
import com.mealchemy.engine.dto.SignalScoresResponse;
import jakarta.validation.constraints.NotNull;
import com.fasterxml.jackson.annotation.JsonProperty;

/* Import classes */

public record SwipeRequest(
    @JsonProperty("recipe_id") @NotNull Integer recipeId,
    @JsonProperty("cuisine_value") @NotNull String cuisineValue,
    @NotNull SwipeAction action,
    @JsonProperty("signal_scores") @NotNull SignalScoresResponse signalScores
){}