package com.mealchemy.recipe.dto;

/* Import libraries */

/* Import classes */

public record RecipeStepRequest(
    @NotNull @Min(1) Integer stepNr,
    @NotBlank String content    
){}