package com.mealchemy.recipe.dto;

/* Import libraries */

import jakarta.validation.constraints.*;
import java.util.*;

/* Import classes */

public record RecipeFullRequest(
    @NotBlank String title,
    String description,
    @NotBlank String cuisineType,
    @NotNull Integer prepTimeMins,
    @NotNull Integer cookingTimeMins,
    @NotNull Integer servingSize,
    String photoUrl,
    String videoUrl,
    String externalUrl,
    boolean isCommunityPublished,
    @NotEmpty List<RecipeIngredientRequest> ingredients,
    @NotEmpty List<RecipeStepRequest> steps,
    @NotNull Integer folderId
)
{}