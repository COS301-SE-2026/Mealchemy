package com.mealchemy.nutritionalgoals.dto;

// imported libraries
import com.fasterxml.jackson.annotation.JsonProperty;

public record NutritionalGoalsResponse(
    @JsonProperty("id") Integer nutritionalGoalId,
    String value,
    String label
) {}

