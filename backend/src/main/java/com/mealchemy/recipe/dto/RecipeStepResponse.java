package com.mealchemy.recipe.dto;

/* Import libraries */

/* Import classes */

public record RecipeStepResponse(
    int stepId,
    int recipeId,
    int stepNr,
    String content
)
{
    public static RecipeStepResponse from (RecipeStep recipeStep)
    {
        return new RecipeStepResponse
        (
            recipeStep.getStepId();
            recipeStep.getRecipeId();
            recipeStep.getStepNr();
            recipeStep.getContent();
        );
    }
}
