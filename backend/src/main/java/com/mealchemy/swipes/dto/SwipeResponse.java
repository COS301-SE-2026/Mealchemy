package com.mealchemy.swipes.dto;

/* Import libraries */
import com.mealchemy.shared.enums.SwipeAction;
import java.time.OffsetDateTime;
import com.fasterxml.jackson.annotation.JsonProperty;

/* Import classes */

public record SwipeResponse(
    @JsonProperty("swipe_id") Integer swipeId,
    @JsonProperty("recipe_id") Integer recipeId,
    @JsonProperty("cuisine_value") String cuisineValue,
    SwipeAction action,
    @JsonProperty("swiped_at") OffsetDateTime swipedAt
)
{
    public static SwipeResponse from(com.mealchemy.swipes.model.Swipe swipe)
    {
        return new SwipeResponse(
            swipe.getSwipeId(),
            swipe.getRecipeId(),
            swipe.getCuisineValue(),
            swipe.getAction(),
            swipe.getSwipedAt()
        );
    }
}