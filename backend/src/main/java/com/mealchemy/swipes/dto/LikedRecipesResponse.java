package com.mealchemy.swipes.dto;

/* Import libraries */
import java.util.List;

/* Import classes */

public record LikedRecipesResponse(
    @com.fasterxml.jackson.annotation.JsonProperty("liked_recipes") List<LikedRecipeItem> likedRecipes
)
{
    public static LikedRecipesResponse empty()
    {
        return new LikedRecipesResponse(List.of());
    }
}