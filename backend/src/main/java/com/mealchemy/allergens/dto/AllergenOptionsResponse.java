package com.mealchemy.allergens.dto;

// imported libraries
import com.fasterxml.jackson.annotation.JsonProperty;

public record AllergenOptionsResponse(
    @JsonProperty("id") Integer allergenId,
    String value,
    String label
) {}

