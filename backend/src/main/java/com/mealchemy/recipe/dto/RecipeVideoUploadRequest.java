package com.mealchemy.recipe.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record RecipeVideoUploadRequest(
    @NotBlank String contentType,
    @NotNull @Positive Long fileSizeBytes
)
{}
