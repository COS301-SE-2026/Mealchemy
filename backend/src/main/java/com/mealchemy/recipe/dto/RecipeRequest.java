package com.mealchemy.recipe.dto;

/* Import libraries */

import java.time.OffsetDateTime;
import jakarta.validation.constraints.*;
import java.util.List;

/* Import classes */

public record RecipeRequest(
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
    Integer folderId,
    List<Integer> equipmentIds
)
{}