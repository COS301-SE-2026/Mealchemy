package com.mealchemy.recipe.dto;

/* Import libraries */

import java.math.BigDecimal;

/* Import classes */

import com.mealchemy.recipe.model.RecipeIngredient;
import com.mealchemy.shared.unitconverter.UnitConverter;

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
    // used by create and update - normalises quantity and unit (stored in canonical g or ml in db)
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

    // used by GET - show the ingredient quantity and unit in the user's preferred measurement system
    public static RecipeIngredientResponse from(RecipeIngredient recipeIngredient, String ingName, UnitConverter.NormalisedQuantity displayQuantity)
    {
        return new RecipeIngredientResponse(
            recipeIngredient.getIngredientId(),
            recipeIngredient.getRecipe().getRecipeId(),
            recipeIngredient.getIngId(),
            ingName,
            displayQuantity.quantity(),
            displayQuantity.unit(),
            recipeIngredient.getSortOrder()
        );
    }
}