package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import jakarta.validation.constraints.*;
import java.util.*;
import java.math.BigDecimal;
import com.fasterxml.jackson.annotation.JsonProperty;

public record PreferenceWeightsRequest(
    @JsonProperty("pantry_match") @NotNull BigDecimal pantryMatch,
    @NotNull BigDecimal cuisine,
    @NotNull BigDecimal nutrition,
    @NotNull BigDecimal freshness,
    @NotNull BigDecimal novelty
)
{}