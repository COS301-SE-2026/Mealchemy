package com.mealchemy.recipe.event;

// represents a request to remove an old recipe photo after database operation succeeds
// not a dto
public record RecipePhotoCleanupEvent(
    Integer recipeId,
    String photoUrl
)
{}
