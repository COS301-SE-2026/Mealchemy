package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import java.util.*;
import com.fasterxml.jackson.annotation.JsonProperty;

public record RecommendationResponse(
    List<RecommendationDto> recommendations,
    @JsonProperty("cuisine_allocation") Map<String, Integer> cuisineAllocation,
    @JsonProperty("total_candidates_after_filter") Integer totalCandidatesAfterFilter,
    @JsonProperty("total_recipes_considered") Integer totalRecipesConsidered
)
{
    public static RecommendationResponse from (List<RecommendationDto> recommendationsIn, Map<String, Integer> cuisineAllocationIn, 
        Integer totalCandidatesAfterFilterIn, Integer totalRecipesConsideredIn)
    {
        return new RecommendationResponse(
            recommendationsIn,
            cuisineAllocationIn,
            totalCandidatesAfterFilterIn,
            totalRecipesConsideredIn
        );
    }
}
