package com.mealchemy.dietaryrestrictions.dto;

// imported libraries
import com.fasterxml.jackson.annotation.JsonProperty;

public record DietaryRestrictionOptionsResponse(
    @JsonProperty("id") Integer dietaryRestrictionId,
    String value,
    String label
) {}

