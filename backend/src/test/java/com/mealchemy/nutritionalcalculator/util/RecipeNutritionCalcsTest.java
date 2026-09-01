package com.mealchemy.nutritionalcalculator.util;

// dtos 
import com.mealchemy.nutritionalcalculator.dto.RecipeIngredientNutrition;
import com.mealchemy.nutritionalcalculator.dto.ScaledIngredientNutrition;
import com.mealchemy.nutritionalcalculator.dto.RecipeNutritionValues;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import java.math.BigDecimal;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;

class RecipeNutritionCalcsTest {

    private ScaledIngredientNutrition recipeIngredient1;
    private ScaledIngredientNutrition recipeIngredient2;

    @BeforeEach
    void setUp() {
        recipeIngredient1 = new ScaledIngredientNutrition(
            1,
            "Hummus",
            BigDecimal.valueOf(200),
            "g",
            BigDecimal.valueOf(166),
            BigDecimal.valueOf(7.9),
            BigDecimal.valueOf(14.3),
            BigDecimal.valueOf(9.6),
            BigDecimal.valueOf(6.0),
            BigDecimal.valueOf(379.0)
        );

    }

    @Test 
    void totalNutritionValuesForRecipe() {
        RecipeNutritionValues result = RecipeNutritionCalcs.sumNutritionValues(List.of(recipeIngredient1, recipeIngredient1));

        assertEquals(0, BigDecimal.valueOf(332.0).compareTo(result.caloriesKcal()));
        assertEquals(0,BigDecimal.valueOf(15.80).compareTo(result.proteinG()));
        assertEquals(0, BigDecimal.valueOf(28.60).compareTo(result.carbsG()));
        assertEquals(0, BigDecimal.valueOf(19.20).compareTo(result.fatG()));
        assertEquals(0, BigDecimal.valueOf(12.00).compareTo(result.fibreG()));
        assertEquals(0, BigDecimal.valueOf(758.00).compareTo(result.sodiumMg()));
    }

    @Test 
    void nutritionaValuesPerServing_forARecipe() {

        RecipeNutritionValues scaledRecipe = new RecipeNutritionValues(
            BigDecimal.valueOf(116),
            BigDecimal.valueOf(7.9),
            BigDecimal.valueOf(14.3),
            BigDecimal.valueOf(9.6),
            BigDecimal.valueOf(6.0),
            BigDecimal.valueOf(379.0)
        );

        RecipeNutritionValues result = RecipeNutritionCalcs.perServing(scaledRecipe, 2);

        assertEquals(0, BigDecimal.valueOf(58.00).compareTo(result.caloriesKcal()));
        assertEquals(0, BigDecimal.valueOf(3.95).compareTo(result.proteinG()));
        assertEquals(0, BigDecimal.valueOf(7.15).compareTo(result.carbsG()));
        assertEquals(0, BigDecimal.valueOf(4.80).compareTo(result.fatG()));
        assertEquals(0, BigDecimal.valueOf(3.00).compareTo(result.fibreG()));
        assertEquals(0, BigDecimal.valueOf(189.50).compareTo(result.sodiumMg()));
    }

    @Test 
    void perServing_ServingsLessOrEqualZero() {

        RecipeNutritionValues totalRecipeNutrition = new RecipeNutritionValues(
            BigDecimal.valueOf(116),
            BigDecimal.valueOf(7.9),
            BigDecimal.valueOf(14.3),
            BigDecimal.valueOf(9.6),
            BigDecimal.valueOf(6.0),
            BigDecimal.valueOf(379.0)
        );

        assertThrows(IllegalArgumentException.class, () -> RecipeNutritionCalcs.perServing(totalRecipeNutrition, 0));
        assertThrows(IllegalArgumentException.class, () -> RecipeNutritionCalcs.perServing(totalRecipeNutrition, -1));
    }
}