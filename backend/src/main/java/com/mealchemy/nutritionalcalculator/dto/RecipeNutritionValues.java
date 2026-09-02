package com.mealchemy.nutritionalcalculator.dto;

import java.math.BigDecimal;
import com.fasterxml.jackson.annotation.JsonProperty;

public record RecipeNutritionValues( //records are immutable and auto generate constructors
    // 6 nutritional value fields
    @JsonProperty("calories_kcal") BigDecimal caloriesKcal,
    @JsonProperty("protein_g") BigDecimal proteinG,
    @JsonProperty("carbs_g") BigDecimal carbsG,
    @JsonProperty("fat_g") BigDecimal fatG,
    @JsonProperty("fibre_g") BigDecimal fibreG,
    @JsonProperty("sodium_mg") BigDecimal sodiumMg
) {}