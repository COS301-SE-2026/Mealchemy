package com.mealchemy.recipe.dto;

/* Import libraries */

import java.time.OffsetDateTime;

/* Import classes */

import com.mealchemy.recipe.model.Recipe;

public record RecipeResponse(
    Integer recipeId,
    Integer ownerId,
    String title,
    String description,
    String cuisineType,
    Integer prepTimeMins,
    Integer cookingTimeMins,
    Integer servingSize,
    String photoUrl,
    String videoUrl,
    String externalUrl,
    boolean isCommunityPublished,
    OffsetDateTime createdAt,
    OffsetDateTime updatedAt
)
{
    public static RecipeResponse from (Recipe recipe)
    {
        return new RecipeResponse(
            recipe.getRecipeId(),
            recipe.getOwnerId(),
            recipe.getTitle(),
            recipe.getDescription(),
            recipe.getCuisineType(),
            recipe.getPrepTimeMins(),
            recipe.getCookingTimeMins(),
            recipe.getServingSize(),
            recipe.getPhotoUrl(),
            recipe.getVideoUrl(),
            recipe.getExternalUrl(),
            recipe.getIsCommunityPublished(),
            recipe.getCreatedAt(),
            recipe.getUpdatedAt()
        );
    }
}