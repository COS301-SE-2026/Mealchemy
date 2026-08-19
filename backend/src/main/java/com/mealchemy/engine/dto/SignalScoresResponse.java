package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import com.fasterxml.jackson.annotation.JsonProperty;

public record SignalScoresResponse(
    @JsonProperty("pantry_coverage") Double pantryCoverage,
    @JsonProperty("cuisine_affinity") Double cuisineAffinity,
    Double nutrition,
    Double freshness,
    Double novelty
)
{
    public static SignalScoresResponse from(Double pantryCoverageIn, Double cuisineAffinityIn, Double nutritionIn, Double freshnessIn, Double noveltyIn)
    {
        return new SignalScoresResponse(
            pantryCoverageIn,
            cuisineAffinityIn,
            nutritionIn,
            freshnessIn,
            noveltyIn
        );
    }
}
