package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import jakarta.validation.constraints.*;
import java.time.OffsetDateTime;
import java.util.*;
import java.math.BigDecimal;
import com.fasterxml.jackson.annotation.JsonProperty;

public record LearningUpdateRequest(
    @JsonProperty("preference_weights") PreferenceWeightsRequest preferenceWeights,
    @JsonProperty("cuisine_affinities") Map<String, BigDecimal> cuisineAffinities,
    List<SwipeUpdateDto> swipes,
    @JsonProperty("state_version") Integer stateVersion
){}