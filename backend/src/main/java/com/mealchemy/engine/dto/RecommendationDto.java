package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import java.math.BigDecimal;
import java.util.*;
import com.fasterxml.jackson.annotation.JsonProperty;

public record RecommendationDto(
    @JsonProperty("recipe_id") Integer recipeId,
    @JsonProperty("cuisine_type") String cuisineType,
    BigDecimal score,
    @JsonProperty("score_breakdown") SignalScoresResponse scoreBreakdown,
    @JsonProperty("pantry_gap_count") Integer pantryGapCount,
    @JsonProperty("missing_ingredients") List<String> missingIngredients
)
{
    public static RecommendationDto from(Integer recipeIdIn, String cuisineTypeIn, BigDecimal scoreIn, 
        SignalScoresResponse scoreBreakdownIn, Integer pantryGapCountIn, List<String> missingIngredientsIn)
    {
        return new RecommendationDto(
            recipeIdIn,
            cuisineTypeIn,
            scoreIn,
            scoreBreakdownIn,
            pantryGapCountIn,
            missingIngredientsIn
        );
    }    
}
