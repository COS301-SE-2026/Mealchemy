package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */

public record SignalScoresResponse(
    Double pantryCoverage,
    Double cuisineAffinity,
    Double nutrition,
    Double freshness,
    Double novelty
)
{
    public Static SignalScoresResponse from(Double pantryCoverageIn, Double cuisineAffinityIn, Double nutritionIn, Double freshnessIn, Double noveltyIn)
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
