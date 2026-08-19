package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import jakarta.validation.constraints.*;
import java.util.*;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import com.fasterxml.jackson.annotation.JsonProperty;

public record PantryEntryRequest(
    @JsonProperty("ing_id") @NotNull Integer ingId,
    @JsonProperty("category_id")  @NotNull Integer categoryId,
    @JsonProperty("quantity") @NotNull BigDecimal quantity,
    @JsonProperty("unit") @NotBlank String unit,
    @JsonProperty("added_at") @NotNull OffsetDateTime addedAt,
    @JsonProperty("shelf_life_days") @NotNull Integer shelfLifeDays,
    @JsonProperty("storageLocation") @NotBlank String storageLocation
)
{}