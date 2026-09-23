package com.mealchemy.recipe.event;

public record RecipeVideoCleanupEvent(
    Integer recipeId,
    String videoUrl
)
{}
