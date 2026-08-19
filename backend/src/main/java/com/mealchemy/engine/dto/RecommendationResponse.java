package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import java.util.*;
import com.fasterxml.jackson.annotation.JsonProperty;

public record RecommendationResponse(
    List<RecommendationDto> recommendations,
    @JsonProperty("pool_size_used") Integer poolSizeUsed,
    @JsonProperty("pool_exhausted") boolean poolExhausted
)
{
    public static RecommendationResponse from (List<RecommendationDto> recommendationsIn, Integer poolSizeIn, boolean poolExhaustedIn)
    {
        return new RecommendationResponse(
            recommendationsIn,
            poolSizeIn,
            poolExhaustedIn
        );
    }
}
