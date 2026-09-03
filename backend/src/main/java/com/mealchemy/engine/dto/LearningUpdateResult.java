package com.mealchemy.engine.dto;

/* Import libraries */
import java.util.Map;
import java.math.BigDecimal;

/* Import classes */

public record LearningUpdateResult(
    Integer stateVersion,
    PreferenceWeightsRequest preferenceWeights,
    Map<String, BigDecimal> cuisineAffinities
){}