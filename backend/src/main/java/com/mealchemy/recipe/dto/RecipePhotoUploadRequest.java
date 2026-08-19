package com.mealchemy.recipe.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

// validates contenttype is present and fle size is postive and present
//backend needs this metadat to vaildate the image and create a signed url with matching upload headers
public record RecipePhotoUploadRequest(
    @NotBlank String contentType,
    @NotNull @Positive Long fileSizeBytes
)
{}
