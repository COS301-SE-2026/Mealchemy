package com.mealchemy.nutritionalcalculator.controller;

// import dtos
import com.mealchemy.nutritionalcalculator.dto.*;
// import services
import com.mealchemy.nutritionalcalculator.service.*;
// for jwt token
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;



@RestController
@RequestMapping("/api/nutritional-calculator") 
public class NutritionalCalculatorController {

    private final NutritionalCalculatorService nutritionalCalculatorService;

    public NutritionalCalculatorController(NutritionalCalculatorService nutritionalCalculatorService) {
        this.nutritionalCalculatorService = nutritionalCalculatorService;
    }

    // get nutritional info for a recipe
    @GetMapping("/{recipeId}")
    public ResponseEntity<RecipeNutritionResponse> getRecipeNutritionalData(@AuthenticationPrincipal String userId, @PathVariable Integer recipeId) {
        return ResponseEntity.ok(nutritionalCalculatorService.getRecipeNutrition(Integer.parseInt(userId), recipeId));
    }

}