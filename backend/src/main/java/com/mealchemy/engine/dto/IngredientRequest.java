package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import jakarta.validation.constraints.*;
import java.util.*;
import java.math.BigDecimal;
import com.fasterxml.jackson.annotation.JsonProperty;

public record IngredientRequest(
    @JsonProperty("ing_id") @NotNull Integer ingId,
    @JsonProperty("category_id") @NotNull Integer categoryId,
    @NotBlank String name,
    @NotNull BigDecimal quantity,
    @NotBlank String unit
)
{}
