package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import java.math.BigDecimal;

public record RecommendationDto(
    Integer recipeId,
    String cuisine,
    BigDecimal score,
    String slotType,
    SignalScoresResponse signalScores
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
