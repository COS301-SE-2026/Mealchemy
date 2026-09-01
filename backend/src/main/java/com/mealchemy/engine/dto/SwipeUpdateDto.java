package com.mealchemy.engine.dto;

/* Import classes */
import com.mealchemy.shared.enums.SwipeAction;

/* Import libraries */
import jakarta.validation.constraints.*;
import java.time.OffsetDateTime;
import com.fasterxml.jackson.annotation.JsonProperty;

public record SwipeUpdateDto(
    @JsonProperty("recipe_id") Integer recipeId,
    String cuisine,
    SwipeAction action,
    @JsonProperty("signal_scores") SignalScoresResponse signalScores,
    Double alpha
){}