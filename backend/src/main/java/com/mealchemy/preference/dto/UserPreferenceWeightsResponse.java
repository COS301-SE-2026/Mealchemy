package com.mealchemy.preference.dto;

/* Import libraries */

import com.fasterxml.jackson.annotation.JsonProperty;
import java.math.BigDecimal;

/* Import classes */

public record UserPreferenceWeightsResponse(
    @JsonProperty("pantry_match") BigDecimal pantryMatch,
    BigDecimal cuisine,
    BigDecimal nutrition,
    BigDecimal freshness,
    BigDecimal novelty
) {}
