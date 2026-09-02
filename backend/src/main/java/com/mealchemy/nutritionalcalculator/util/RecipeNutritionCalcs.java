package com.mealchemy.nutritionalcalculator.util;

import com.mealchemy.nutritionalcalculator.dto.RecipeIngredientNutrition;
import com.mealchemy.nutritionalcalculator.dto.ScaledIngredientNutrition;
import com.mealchemy.nutritionalcalculator.dto.RecipeNutritionValues;

import java.util.List;
import java.math.BigDecimal;
import java.math.RoundingMode;

public class RecipeNutritionCalcs {

    private static final int SCALE = 2;

    private RecipeNutritionCalcs() {}

    public static RecipeNutritionValues sumNutritionValues(List<ScaledIngredientNutrition> scaledIngredientValues) {
        
        BigDecimal totalCaloriesKcal = BigDecimal.ZERO;
        BigDecimal totalProteinG = BigDecimal.ZERO;
        BigDecimal totalCarbsG = BigDecimal.ZERO;
        BigDecimal totalFatG = BigDecimal.ZERO;
        BigDecimal totalFibreG = BigDecimal.ZERO;
        BigDecimal totalSodiumMg = BigDecimal.ZERO;

        for(ScaledIngredientNutrition ingredient : scaledIngredientValues) {
            totalCaloriesKcal = totalCaloriesKcal.add(ingredient.caloriesKcal());
            totalProteinG = totalProteinG.add(ingredient.proteinG());  
            totalCarbsG = totalCarbsG.add(ingredient.carbsG());
            totalFatG = totalFatG.add(ingredient.fatG());  
            totalFibreG = totalFibreG.add(ingredient.fibreG());
            totalSodiumMg = totalSodiumMg.add(ingredient.sodiumMg());
        }

        return new RecipeNutritionValues(
            totalCaloriesKcal,
            totalProteinG,
            totalCarbsG,
            totalFatG,
            totalFibreG,
            totalSodiumMg
        );
    }

    public static RecipeNutritionValues perServing(RecipeNutritionValues totalNutritionValues, Integer servings) {
        if (servings == null || servings <= 0) {
        throw new IllegalArgumentException("Servings must be greater than 0, got: " + servings);
    }
        BigDecimal servingSize = BigDecimal.valueOf(servings);

        BigDecimal perServingCaloriesKcal = totalNutritionValues.caloriesKcal().divide(servingSize, 2, RoundingMode.HALF_UP);
        BigDecimal perServingProteinG = totalNutritionValues.proteinG().divide(servingSize, 2, RoundingMode.HALF_UP);  
        BigDecimal perServingCarbsG = totalNutritionValues.carbsG().divide(servingSize, 2, RoundingMode.HALF_UP);
        BigDecimal perServingFatG = totalNutritionValues.fatG().divide(servingSize, 2, RoundingMode.HALF_UP); 
        BigDecimal perServingFibreG = totalNutritionValues.fibreG().divide(servingSize, 2, RoundingMode.HALF_UP);
        BigDecimal perServingSodiumMg = totalNutritionValues.sodiumMg().divide(servingSize, 2, RoundingMode.HALF_UP);

        return new RecipeNutritionValues(
            perServingCaloriesKcal,
            perServingProteinG,
            perServingCarbsG,
            perServingFatG,
            perServingFibreG,
            perServingSodiumMg
        );
    }
   
}