package com.mealchemy.recipe.dto;

/* Import libraries */

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import java.util.*;

/* Import classes */

public record RecipeUpdateRequest(
    @NotBlank String title,
    String description,
    @NotBlank String cuisineType,
    @NotNull Integer prepTimeMins,
    @NotNull Integer cookingTimeMins,
    @NotNull Integer servingSize,
    String photoUrl,
    boolean removePhoto,
    String videoUrl,
    String externalUrl,
    boolean isCommunityPublished,
    List<@Valid RecipeIngredientRequest> ingredients,
    List<@Valid RecipeStepRequest> steps
)
{}
