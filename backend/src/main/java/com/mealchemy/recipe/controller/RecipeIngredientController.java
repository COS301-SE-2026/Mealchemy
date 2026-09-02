package com.mealchemy.recipe.controller;

/* Import libraries */

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;
import jakarta.validation.Valid;

/* Import classes */

import com.mealchemy.recipe.dto.RecipeIngredientRequest;
import com.mealchemy.recipe.dto.RecipeIngredientResponse;
import com.mealchemy.recipe.service.RecipeIngredientService;

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
@RequestMapping("/ingredients")
@Tag(name = "Recipe Ingredients", description = "Ingredient lines belonging to a recipe")
public class RecipeIngredientController
{
    private final RecipeIngredientService recipeIngredientService;

    public RecipeIngredientController(RecipeIngredientService recipeIngredientService)
    {
        this.recipeIngredientService = recipeIngredientService;
    }

    /* Mapping functions */

    // Get
    @Operation(summary = "Get all ingredients for a recipe", description = "Returns the ingredient lines for a recipe, converted to the authenticated user's preferred unit of measurement.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Ingredients retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = RecipeIngredientResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "User profile not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/recipe/{recipeId}")
    public List<RecipeIngredientResponse> getAllIngredientsByRecipeId(@PathVariable Integer recipeId, @AuthenticationPrincipal String userId)
    {
        return recipeIngredientService.getAllIngredientsByRecipeId(recipeId, Integer.parseInt(userId));
    }


    // Post
    @Operation(summary = "Adds an ingredient to a recipe", description = "Adds an ingredient line to a recipe. Only the owner may modify a recipe's ingredients.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Ingredient line created successfully", content = @Content(schema = @Schema(implementation = RecipeIngredientResponse.class))),
        @ApiResponse(responseCode = "400", description = "The supplied ingredient does not exist in the catalogue", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this recipe", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found, or user profile not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/recipe/{recipeId}/ingredient/create")
    public RecipeIngredientResponse createRecipeIngredient(@Valid @RequestBody RecipeIngredientRequest request, @PathVariable Integer recipeId, 
        @AuthenticationPrincipal String ownerId)
    {
        return recipeIngredientService.createRecipeIngredient(request, recipeId, Integer.parseInt(ownerId));
    }


    // Put
    @Operation(summary = "Update a recipe ingredient", description = "Updates an existing ingredient line on a recipe. Only the owner may modify a recipe's ingredients")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Ingredient line updated successfully", content = @Content(schema = @Schema(implementation = RecipeIngredientResponse.class))),
        @ApiResponse(responseCode = "400", description = "The supplied ingredient does not exist in the catalogue", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this recipe, or the ingredient line does not belong to the specified recipe", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found, ingredient line not found, or user profile not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/recipe/{recipeId}/ingredient/{id}/edit")
    public RecipeIngredientResponse updateRecipeIngredient(@PathVariable int id, @Valid @RequestBody RecipeIngredientRequest request, 
        @PathVariable Integer recipeId, @AuthenticationPrincipal String ownerId)
    {
        return recipeIngredientService.updateRecipeIngredient(id, request, recipeId, Integer.parseInt(ownerId));
    }


    // Delete
    @Operation(summary = "Delete a recipe ingredient", description = "Removes an ingredient line from a recipe. Only the owner may modify a recipe's ingredients")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Ingredient line deleted successfully"),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this recipe, or the ingredient line does not belong to the specified recipe", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found, or ingredient line not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("/recipe/{recipeId}/ingredient/{id}/delete")
    public ResponseEntity<Void> deleteRecipeIngredient(@PathVariable int id, @PathVariable Integer recipeId, @AuthenticationPrincipal String ownerId)
    {
        recipeIngredientService.deleteRecipeIngredient(id, recipeId, Integer.parseInt(ownerId));
        return ResponseEntity.noContent().build();
    }
}