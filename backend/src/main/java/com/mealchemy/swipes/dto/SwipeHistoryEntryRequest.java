package com.mealchemy.swipes.dto;

/* Import classes */
import com.mealchemy.shared.enums.SwipeAction;

/* Import libraries */
import jakarta.validation.constraints.*;
import java.time.OffsetDateTime;
import com.fasterxml.jackson.annotation.JsonProperty;

public record SwipeHistoryEntryRequest(
    @JsonProperty("recipe_id") @NotNull Integer recipeId,
    @NotNull SwipeAction action,
    @JsonProperty("swiped_at") @NotNull OffsetDateTime swipedAt
)
{}
