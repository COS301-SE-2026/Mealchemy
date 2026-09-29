package com.mealchemy.moderation.dto;

import com.mealchemy.recipe.dto.RecipeResponse;
import com.mealchemy.shared.enums.FlagStatus;
import java.time.OffsetDateTime;

// imported libraries
import com.fasterxml.jackson.annotation.JsonProperty;

public record FlaggedRecipeDetailResponse( // summaries flagged recipe
    @JsonProperty("flagged_id") Integer flaggedId,
    @JsonProperty("recipe_id") Integer recipeId, 
    @JsonProperty("recipe_title") String recipeTitle, 
    @JsonProperty("recipe_photo_url") String recipePhotoUrl, 
    @JsonProperty("flagged_by_user_id") Integer flaggedByUserId, 
    @JsonProperty("reason_value") String reasonValue, 
    @JsonProperty("reason_label") String reasonLabel, 
    FlagStatus status, 
    @JsonProperty("flagged_at") OffsetDateTime flaggedAt,
    RecipeResponse recipeResponse
) {}

