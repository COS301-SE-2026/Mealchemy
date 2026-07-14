package com.mealchemy.recipe.dto;

/* Import libraries */

import java.math.BigDecimal;
import jakarta.validation.constraints.*;

/* Import classes */

public record RecipeIngredientRequest(
    @NotNull Integer ingId,
    @NotNull BigDecimal quantity,
    @NotBlank String unit,
    @NotNull Integer sortOrder
){}