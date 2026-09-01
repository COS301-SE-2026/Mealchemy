package com.mealchemy.nutritionalcalculator.util;

// dtos 
import com.mealchemy.nutritionalcalculator.dto.RecipeIngredientNutrition;
import com.mealchemy.nutritionalcalculator.dto.ScaledIngredientNutrition;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import java.math.BigDecimal;

import org.junit.jupiter.api.BeforeEach;

class NutritionScalerTest {

    private RecipeIngredientNutrition recipeIngredient1;
    private RecipeIngredientNutrition recipeIngredient2;

    @BeforeEach
    void setUp() {
        recipeIngredient1 = new RecipeIngredientNutrition(
            1,
            "Hummus",
            BigDecimal.valueOf(200),
            "g",
            166,
            BigDecimal.valueOf(7.9),
            BigDecimal.valueOf(14.3),
            BigDecimal.valueOf(9.6),
            BigDecimal.valueOf(6.0),
            BigDecimal.valueOf(379.0)
        );

        recipeIngredient2 = new RecipeIngredientNutrition(
            2,
            "Rice Cakes",
            BigDecimal.valueOf(30),
            "g",
            116,
            BigDecimal.valueOf(2.5),
            null,
            null,
            null,
            BigDecimal.valueOf(75.0)
        );
    }

    @Test 
    void scaleNutriton_byIngredientQuantity_noFieldIsNull() {
        ScaledIngredientNutrition result = NutritionScaler.scale(recipeIngredient1);

        assertEquals(1 , result.ingId());
        assertEquals("Hummus" , result.name());
        assertEquals(0, BigDecimal.valueOf(200).compareTo(result.quantity()));
        assertEquals("g" , result.unit());
        assertEquals(0, BigDecimal.valueOf(332.0).compareTo(result.caloriesKcal()));
        assertEquals(0,BigDecimal.valueOf(15.80).compareTo(result.proteinG()));
        assertEquals(0, BigDecimal.valueOf(28.60).compareTo(result.carbsG()));
        assertEquals(0, BigDecimal.valueOf(19.20).compareTo(result.fatG()));
        assertEquals(0, BigDecimal.valueOf(12.00).compareTo(result.fibreG()));
        assertEquals(0, BigDecimal.valueOf(758.00).compareTo(result.sodiumMg()));
    }

    @Test 
    void scaleNutriton_byIngredientQuantity_someNutritionFieldsAreNull() {
        ScaledIngredientNutrition result = NutritionScaler.scale(recipeIngredient2);

        assertEquals(2 , result.ingId());
        assertEquals("Rice Cakes" , result.name());
        assertEquals(0, BigDecimal.valueOf(30).compareTo(result.quantity()));
        assertEquals("g" , result.unit());
        assertEquals(0, BigDecimal.valueOf(34.80).compareTo(result.caloriesKcal()));
        assertEquals(0, BigDecimal.valueOf(0.75).compareTo(result.proteinG()));
        assertEquals(0, BigDecimal.ZERO.compareTo(result.carbsG()));
        assertEquals(0, BigDecimal.ZERO.compareTo(result.fatG()));
        assertEquals(0, BigDecimal.ZERO.compareTo(result.fibreG()));
        assertEquals(0, BigDecimal.valueOf(22.50).compareTo(result.sodiumMg()));
    }
}