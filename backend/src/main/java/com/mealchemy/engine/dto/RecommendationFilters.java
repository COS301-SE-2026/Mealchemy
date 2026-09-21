package com.mealchemy.engine.dto;

/* Import libraries */

import java.util.List;

/* Import classes */

public record RecommendationFilters(
    Integer maxCookingTimeMins,
    Integer maxTotalTimeMins,
    List<String> dietaryTags
)
{
    public static RecommendationFilters none()
    {
        return new RecommendationFilters(null, null, null);
    }
}