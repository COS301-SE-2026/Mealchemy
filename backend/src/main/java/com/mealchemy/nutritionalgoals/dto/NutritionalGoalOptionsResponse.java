package com.mealchemy.nutritionalgoals.dto;

// imported libraries
import com.fasterxml.jackson.annotation.JsonProperty;

public record NutritionalGoalOptionsResponse(
    @JsonProperty("id") Integer nutritionalGoalId,
    String value,
    String label
) {}

