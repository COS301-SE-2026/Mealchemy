package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import com.fasterxml.jackson.annotation.JsonProperty;

public record SignalScoresResponse(
    @JsonProperty("pantry_match") Double pantryMatch,
    @JsonProperty("cuisine") Double cuisine,
    Double nutrition,
    Double freshness,
    Double novelty
)
{
    public static SignalScoresResponse from(Double pantryMatchIn, Double cuisineIn, Double nutritionIn, Double freshnessIn, Double noveltyIn)
    {
        return new SignalScoresResponse(
            pantryMatchIn,
            cuisineIn,
            nutritionIn,
            freshnessIn,
            noveltyIn
        );
    }
}
