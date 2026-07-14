package com.mealchemy.recipe.dto;

/* Import libraries */

/* Import classes */

import com.mealchemy.recipe.model.RecipeStep;

public record RecipeStepResponse(
    Integer stepId,
    Integer recipeId,
    Integer stepNr,
    String content
)
{
    public static RecipeStepResponse from (RecipeStep recipeStep)
    {
        return new RecipeStepResponse
        (
            recipeStep.getStepId(),
            recipeStep.getRecipeId(),
            recipeStep.getStepNr(),
            recipeStep.getContent()
        );
    }
}
