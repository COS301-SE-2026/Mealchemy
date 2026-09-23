package com.mealchemy.recipe.dto;

import java.time.OffsetDateTime;
import java.util.Map;

public record RecipeVideoUploadResponse(
    String uploadUrl,
    String videoUrl,
    Map<String, String> requiredHeaders,
    OffsetDateTime expiresAt
)
{}
