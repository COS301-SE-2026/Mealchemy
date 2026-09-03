package com.mealchemy.nutritionalcalculator.util;

import com.mealchemy.nutritionalcalculator.dto.RecipeIngredientNutrition;
import com.mealchemy.nutritionalcalculator.dto.ScaledIngredientNutrition;

import java.math.BigDecimal;
import java.math.RoundingMode;

public class NutritionScaler {

    private static final int SCALE = 2;

    private NutritionScaler() {}

    public static ScaledIngredientNutrition scale(RecipeIngredientNutrition recipeIngredient) {
        BigDecimal grams = recipeIngredient.quantity();

        BigDecimal caloriesKcal = scaleValue(recipeIngredient.caloriesKcal() == null ? null : BigDecimal.valueOf(recipeIngredient.caloriesKcal()), grams);
        BigDecimal proteinG = scaleValue(recipeIngredient.proteinG(), grams);
        BigDecimal carbsG = scaleValue(recipeIngredient.carbsG(), grams);
        BigDecimal fatG = scaleValue(recipeIngredient.fatG(), grams);
        BigDecimal fibreG = scaleValue(recipeIngredient.fibreG(), grams);
        BigDecimal sodiumMg = scaleValue(recipeIngredient.sodiumMg(), grams);

        return new ScaledIngredientNutrition(
            recipeIngredient.ingId(),
            recipeIngredient.name(),
            recipeIngredient.quantity(),
            recipeIngredient.unit(),
            caloriesKcal,
            proteinG,
            carbsG,
            fatG,
            fibreG,
            sodiumMg
        );
    }

    // scaling helper
    private static BigDecimal scaleValue(BigDecimal valPer100g, BigDecimal grams) {
        if (valPer100g == null) { // if value is null set quantity to zero
            return BigDecimal.ZERO.setScale(SCALE, RoundingMode.HALF_UP);
        }

        return valPer100g.divide(BigDecimal.valueOf(100), 6, RoundingMode.HALF_UP).multiply(grams).setScale(SCALE, RoundingMode.HALF_UP);
    }
}