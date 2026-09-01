package com.mealchemy.nutritionalcalculator.controller;

// import dtos
import com.mealchemy.nutritionalcalculator.dto.*;
// import services
import com.mealchemy.nutritionalcalculator.service.*;
// for jwt token
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

// swagger 
import com.mealchemy.shared.dto.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/nutritional-calculator") 
@Tag(name = "Nutritional Calculator", description = "Calculated nutritional breakdown for a recipe")
public class NutritionalCalculatorController {

    private final NutritionalCalculatorService nutritionalCalculatorService;

    public NutritionalCalculatorController(NutritionalCalculatorService nutritionalCalculatorService) {
        this.nutritionalCalculatorService = nutritionalCalculatorService;
    }

    // swagger comments
    @Operation(summary = "Get nutritional data for a recipe", description = "Returns total, per-serving, and per-ingredient nutritional values for a recipe, scaled from the ingredient catalogue.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Nutritional data calculated successfully", content = @Content(schema = @Schema(implementation = RecipeNutritionResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found, or not accessible to the authenticated user, or has no ingredients", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/{recipeId}")
    public ResponseEntity<RecipeNutritionResponse> getRecipeNutritionalData(@AuthenticationPrincipal String userId, @PathVariable Integer recipeId) {
        return ResponseEntity.ok(nutritionalCalculatorService.getRecipeNutrition(Integer.parseInt(userId), recipeId));
    }

}