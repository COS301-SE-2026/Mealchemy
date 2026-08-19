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
    @NotNull BigDecimal quantity,
    @NotBlank String unit,
    @JsonProperty("added_at") @NotNull OffsetDateTime addedAt,
    @JsonProperty("shelf_life_days") @NotNull Integer shelfLifeDays,
    @JsonProperty("storage_location") @NotBlank String storageLocation
)
{}