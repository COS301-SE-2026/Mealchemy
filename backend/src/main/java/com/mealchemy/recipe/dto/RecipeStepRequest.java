package com.mealchemy.recipe.dto;

/* Import libraries */

import jakarta.validation.constraints.*;

/* Import classes */

public record RecipeStepRequest(
    @NotNull @Min(1) Integer stepNr,
    @NotBlank String content    
){}