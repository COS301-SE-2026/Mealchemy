package com.mealchemy.recipe.dto;

/* Import libraries */

/* Import classes */

public record RecipeIngredientResponse(
    @NotNull BigDecimal quantity,
    @NotNull String unit,
    @NotNull int sortOrder
){}