package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import jakarta.validation.constraints.*;
import java.util.*;
import java.math.BigDecimal;
import java.time.OffsetDateTime;

public record PantryEntryRequest(
    @NotNull Integer ingId,
    @NotNull Integer categoryId,
    @NotNull BigDecimal quantity,
    @NotBlank String unit,
    @NotNull OffsetDateTime addedAt,
    @NotNull Integer shelfLifeDays,
    @NotBlank String storageLocation
)
{}