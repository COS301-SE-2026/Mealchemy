package com.mealchemy.moderation.dto;

// imported libraries
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;

public record FlagRequest(
    @JsonProperty("reason_value") @NotBlank String reasonValue
) {}

