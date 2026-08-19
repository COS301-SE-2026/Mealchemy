package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import java.math.BigDecimal;
import com.fasterxml.jackson.annotation.JsonProperty;

public record RecommendationDto(
    @JsonProperty("recipe_id") Integer recipeId,
    String cuisine,
    BigDecimal score,
    @JsonProperty("slot_type") String slotType,
    @JsonProperty("signal_scores") SignalScoresResponse signalScores
)
{
    public static RecommendationDto from(Integer recipeIdIn, String cuisineIn, BigDecimal scoreIn, String slotTypeIn, SignalScoresResponse signalScoresIn)
    {
        return new RecommendationDto(
            recipeIdIn,
            cuisineIn,
            scoreIn,
            slotTypeIn,
            signalScoresIn
        );
    }    
}
