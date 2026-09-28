package com.mealchemy.recipe.dto;

/* Import libraries */

/* Import classes */

import com.mealchemy.recipe.model.RecipeEquipment;

public record RecipeEquipmentResponse(
    Integer recipeEquipmentId,
    Integer recipeId,
    Integer equipmentId,
    String value,
    String label
)
{

    public static RecipeEquipmentResponse from (RecipeEquipment recipeEquipment)
    {
        return new RecipeEquipmentResponse(
            recipeEquipment.getRecipeEquipmentId(),
            recipeEquipment.getRecipe().getRecipeId(),
            recipeEquipment.getEquipment().getEquipmentId(),
            recipeEquipment.getEquipment().getEquipmentValue(),
            recipeEquipment.getEquipment().getEquipmentLabel()
        );
    }
}