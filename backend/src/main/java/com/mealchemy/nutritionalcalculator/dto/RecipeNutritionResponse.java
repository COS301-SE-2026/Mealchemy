package com.mealchemy.nutritionalcalculator.dto;

import java.util.List;
import java.math.BigDecimal;
import com.fasterxml.jackson.annotation.JsonProperty;

public record RecipeNutritionResponse( //records are immutable and auto generate constructors
    @JsonProperty("recipe_id") Integer recipeId,
    Integer servings,
    RecipeNutritionValues totals,
    @JsonProperty("per_serving") RecipeNutritionValues perServing,
    List<ScaledIngredientNutrition> ingredients
) {}