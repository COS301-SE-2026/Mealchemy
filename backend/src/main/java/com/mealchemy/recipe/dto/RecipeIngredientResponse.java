package com.mealchemy.recipe.dto;

/* Import libraries */

import java.math.BigDecimal;

/* Import classes */

import com.mealchemy.recipe.model.RecipeIngredient;

public record RecipeIngredientResponse(
    Integer ingredientId,
    Integer recipeId,
    Integer ingId,
    String ingName,
    BigDecimal quantity,
    String unit,
    Integer sortOrder
)
{
    public static RecipeIngredientResponse from (RecipeIngredient recipeIngredient, String ingName)
    {
        return new RecipeIngredientResponse(
            recipeIngredient.getIngredientId(),
            recipeIngredient.getRecipe().getRecipeId(),
            recipeIngredient.getIngId(),
            ingName,
            recipeIngredient.getQuantity(),
            recipeIngredient.getUnit(),
            recipeIngredient.getSortOrder()
        );
    }
}