package com.mealchemy.engine.dto;

/* Import libraries */
import java.util.List;
import java.util.Map;

/* Import classes */

public record EnrichedRecommendationResponse(
    List<EnrichedRecommendationItem> recommendations,
    Map<String, Integer> cuisineAllocation,
    Integer totalCandidatesAfterFilter,
    Integer totalRecipesConsidered
){
    public static EnrichedRecommendationResponse empty()
    {
        return new EnrichedRecommendationResponse(List.of(), Map.of(), 0, 0);
    }
}