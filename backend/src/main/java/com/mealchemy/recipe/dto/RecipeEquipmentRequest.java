package com.mealchemy.recipe.dto;

/* Import libraries */

import jakarta.validation.constraints.*;

/* Import classes */

public record RecipeEquipmentRequest(
    @NotNull Integer equipmentId
){}