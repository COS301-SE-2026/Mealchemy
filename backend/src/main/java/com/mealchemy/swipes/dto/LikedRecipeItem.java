package com.mealchemy.swipes.dto;

/* Import libraries */
import java.time.OffsetDateTime;
import com.fasterxml.jackson.annotation.JsonProperty;

/* Import classes */
import com.mealchemy.recipe.dto.RecipeResponse;

public record LikedRecipeItem(
    @JsonProperty("recipe_id") Integer recipeId,
    @JsonProperty("cuisine_value") String cuisineValue,
    @JsonProperty("liked_at") OffsetDateTime likedAt,
    RecipeResponse recipe
){}