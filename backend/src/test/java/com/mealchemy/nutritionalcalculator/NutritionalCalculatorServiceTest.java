package com.mealchemy.nutritionalcalculator.service;

import com.mealchemy.nutritionalcalculator.dto.RecipeIngredientNutrition;
import com.mealchemy.nutritionalcalculator.dto.RecipeNutritionResponse;
import com.mealchemy.nutritionalcalculator.repository.NutritionalCalculatorRepository;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.repository.RecipeRepository;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class NutritionalCalculatorServiceTest {
    // @Mock - create fake version of dependency
    @Mock private NutritionalCalculatorRepository nutritionalCalculatorRepository;
    @Mock private RecipeRepository recipeRepository; 

    private NutritionalCalculatorService nutritionalCalculatorService;

    @BeforeEach
    void setup() {
        nutritionalCalculatorService = new NutritionalCalculatorService(nutritionalCalculatorRepository, recipeRepository);
    }

    // GET nutritional data
    @Test
    void getRecipeNutrition_recipeExistsAndAccesible_returnsCorrectValues() {
        // Arrange 
        Recipe recipe = mock(Recipe.class);
        when(recipe.getServingSize()).thenReturn(2);
        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.of(recipe));

        RecipeIngredientNutrition ingredient = new RecipeIngredientNutrition(
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

        when(nutritionalCalculatorRepository.getRecipeIngredientsNutrition(1)).thenReturn(List.of(ingredient));

        // Act
        RecipeNutritionResponse response = nutritionalCalculatorService.getRecipeNutrition(1, 1);

        // Assert
        assertEquals(1, response.recipeId());
        assertEquals(2, response.servings());
        assertEquals(1, response.ingredients().size());
        assertEquals(0, BigDecimal.valueOf(332.0).compareTo(response.totals().caloriesKcal()));
        assertEquals(0, BigDecimal.valueOf(166.0).compareTo(response.perServing().caloriesKcal()));

    }

    @Test
    void getRecipeNutrition_recipeDoesNotExistsOrNotAccesible_throwsNotFound() {
        // Arrange
        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.empty());

        // Act and Assert
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class, 
            () -> nutritionalCalculatorService.getRecipeNutrition(1, 1));
        
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        }

    @Test
    void getRecipeNutrition_recipeExistsButNoIngredients_throwsNotFound() {
        // Arrange
        Recipe recipe = mock(Recipe.class);
        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.of(recipe));
        when(nutritionalCalculatorRepository.getRecipeIngredientsNutrition(1)).thenReturn(List.of());

        // Act and Assert
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class, 
            () -> nutritionalCalculatorService.getRecipeNutrition(1, 1));
        
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        }
}