package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import java.util.*;

public class RecommendationResponse(
    List<RecommendationDto> recommendations,
    Integer poolSizeUsed,
    boolean poolExhausted
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
