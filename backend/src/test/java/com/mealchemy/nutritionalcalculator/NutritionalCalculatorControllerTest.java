package com.mealchemy.nutritionalcalculator.controller;

// dtos
import com.mealchemy.nutritionalcalculator.dto.RecipeNutritionResponse;
import com.mealchemy.nutritionalcalculator.dto.RecipeNutritionValues;
import com.mealchemy.nutritionalcalculator.dto.ScaledIngredientNutrition;
// service
import com.mealchemy.nutritionalcalculator.service.NutritionalCalculatorService;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.server.ResponseStatusException;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.config.JwtUtil;

import java.util.List;
import java.math.BigDecimal;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;

import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;


@WebMvcTest(NutritionalCalculatorController.class)
public class NutritionalCalculatorControllerTest {

    // setup
    @TestConfiguration
    static class TestSecurityConfig {
        @Bean
        public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
            http
                .csrf(AbstractHttpConfigurer::disable)
                .authorizeHttpRequests(auth -> auth.anyRequest().permitAll());
            return http.build();
        }
    }

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private NutritionalCalculatorService nutritionalCalculatorService;

    @MockitoBean
    private JwtUtil jwtUtil;

    // ========== GET Testing (GET /api/nutritional-calculator{recipeId}) ==========

    @Test 
    void getRecipeNutrition_returns200() throws Exception {
        // Arrange 
        RecipeNutritionValues totalNutrition = new RecipeNutritionValues(
            BigDecimal.valueOf(166.0),
            BigDecimal.valueOf(7.9),
            BigDecimal.valueOf(14.3),
            BigDecimal.valueOf(9.6),
            BigDecimal.valueOf(6.0),
            BigDecimal.valueOf(379.0)
        );

        RecipeNutritionValues perServing = new RecipeNutritionValues(
            BigDecimal.valueOf(83.0),
            BigDecimal.valueOf(3.95),
            BigDecimal.valueOf(7.15),
            BigDecimal.valueOf(4.8),
            BigDecimal.valueOf(3.0),
            BigDecimal.valueOf(189.5)
        );

        ScaledIngredientNutrition recipeIngredient1 = new ScaledIngredientNutrition(
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

        ScaledIngredientNutrition recipeIngredient2 = new ScaledIngredientNutrition(
            2,
            "Rice Cakes",
            BigDecimal.valueOf(30),
            "g",
            BigDecimal.valueOf(116),
            BigDecimal.valueOf(2.5),
            BigDecimal.ZERO,
            BigDecimal.ZERO,
            BigDecimal.ZERO,
            BigDecimal.valueOf(75.0)
        );
        
        RecipeNutritionResponse recipeNutrition = new RecipeNutritionResponse(
            1,
            2,
            totalNutrition,
            perServing,
            List.of(recipeIngredient1, recipeIngredient2)
        );

        when(nutritionalCalculatorService.getRecipeNutrition(anyInt(), eq(1))).thenReturn(recipeNutrition);

        // Act and assert
        mockMvc.perform(get("/api/nutritional-calculator/{recipeId}", 1).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$.recipe_id").value(1))
                .andExpect(jsonPath("$.servings").value(2))
                .andExpect(jsonPath("$.totals.calories_kcal").value(166.0))
                .andExpect(jsonPath("$.per_serving.calories_kcal").value(83.0))
                .andExpect(jsonPath("$.ingredients[0].ing_id").value(1))
                .andExpect(jsonPath("$.ingredients[0].name").value("Hummus"))
                .andExpect(jsonPath("$.ingredients[1].ing_id").value(2))
                .andExpect(jsonPath("$.ingredients[1].name").value("Rice Cakes"));
    }

    @Test
    void getRecipeNutrition_recipeNotFoundOrNotAccessible_returns404() throws Exception {
        // Arrange
        when(nutritionalCalculatorService.getRecipeNutrition(anyInt(), eq(1))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found or not accessible"));

        // Act and Assert
        mockMvc.perform(get("/api/nutritional-calculator/{recipeId}", 1)
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Recipe not found or not accessible"));
    }

    @Test
    void getRecipeNutrition_recipeIdNotInt_return400() throws Exception {
        // Act and Assert
        mockMvc.perform(get("/api/nutritional-calculator/{recipeId}", "not-int")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isBadRequest());
               
    }
}