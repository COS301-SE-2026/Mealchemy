package com.mealchemy.recipe.dto;

/* Import libraries */

/* Import classes */

public record RecipeIngredientResponse(
    int ingredientId,
    int recipeId,
    int ingId,
    BigDecimal quantity,
    String unit,
    int sortOrder
)
{
    public static RecipeIngredientResponse from (RecipeIngredient recipeIngredient)
    {
        return new RecipeIngredientResponse(
            recipeIngredient.getIngredientId(),
            recipeIngredient.getRecipeId(),
            recipeIngredient.getIngId(),
            recipeIngredient.getQuantity(),
            recipeIngredient.getUnit(),
            recipeIngredient.getSortOrder()
        );
    }
}