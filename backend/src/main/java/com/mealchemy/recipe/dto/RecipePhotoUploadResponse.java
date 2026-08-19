package com.mealchemy.recipe.dto;

import java.time.OffsetDateTime;
import java.util.Map;

public record RecipePhotoUploadResponse(
    String uploadUrl,
    String photoUrl,
    Map<String, String> requiredHeaders,
    OffsetDateTime expiresAt
)
{}
