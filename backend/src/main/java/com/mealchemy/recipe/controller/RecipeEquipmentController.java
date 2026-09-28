package com.mealchemy.recipe.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.List;

import com.mealchemy.recipe.dto.RecipeEquipmentResponse;
import com.mealchemy.recipe.service.RecipeEquipmentService;

import com.mealchemy.shared.dto.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/recipeequipment")
@Tag(name = "Recipe Equipment", description = "Read-only lookup of the equipment attached to a recipe")
public class RecipeEquipmentController
{
    private final RecipeEquipmentService recipeEquipmentService;
    
    public RecipeEquipmentController(RecipeEquipmentService recipeEquipmentService)
    {
        this.recipeEquipmentService = recipeEquipmentService;
    }


    // Get
    @Operation(summary = "Get all equipment for a recipe", description = "Returns the equipment attached to a recipe. Caller must have access to the recipe.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Equipment retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = RecipeEquipmentResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/recipe/{recipeId}")
    public List<RecipeEquipmentResponse> getAllEquipmentByRecipeId(@PathVariable Integer recipeId, @AuthenticationPrincipal String userId)
    {
        return recipeEquipmentService.getAllEquipmentByRecipeId(recipeId, Integer.parseInt(userId));
    }

}