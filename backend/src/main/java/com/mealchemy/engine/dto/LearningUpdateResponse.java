package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import jakarta.validation.constraints.*;
import java.time.OffsetDateTime;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.*;
import java.math.BigDecimal;

public record LearningUpdateResponse(
    @JsonProperty("preference_weights") PreferenceWeightsRequest preferenceWeights,
    @JsonProperty("cuisine_affinities") Map<String, BigDecimal> cuisineAffinities,
    @JsonProperty("state_version") Integer stateVersion
){}