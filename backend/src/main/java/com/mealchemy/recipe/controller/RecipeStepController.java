package com.mealchemy.recipe.controller;

/* Import libraries */

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;
import jakarta.validation.Valid;

/* Import classes */

import com.mealchemy.recipe.dto.RecipeStepRequest;
import com.mealchemy.recipe.dto.RecipeStepResponse;
import com.mealchemy.recipe.service.RecipeStepService;
import com.mealchemy.recipe.dto.RecipeStepReorderRequest;

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
@RequestMapping("/steps")
@Tag(name = "Recipe Steps", description = "Ordered instruction steps belonging to a recipe")
public class RecipeStepController
{
    private final RecipeStepService recipeStepService;
    
    public RecipeStepController(RecipeStepService recipeStepService)
    {
        this.recipeStepService = recipeStepService;
    }

    /* Mapping functions */

    // Get
    @Operation(summary = "Get all steps for a recipe", description = "Returns the ordered steps for a recipe.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Steps retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = RecipeStepResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/recipe/{recipeId}")
    public List<RecipeStepResponse> getAllStepsByRecipeId(@PathVariable Integer recipeId)
    {
        return recipeStepService.getAllStepsByRecipeId(recipeId);
    }


    // Post
    @Operation(summary = "Adds a step to a recipe", description = "Adds a new instruction step to a recipe. Only the owner may modify a recipe's steps.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Step created successfully", content = @Content(schema = @Schema(implementation = RecipeStepResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this recipe", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/recipe/{recipeId}/step/create")
    public RecipeStepResponse createRecipeStep(@Valid @RequestBody RecipeStepRequest request, @PathVariable Integer recipeId, 
        @AuthenticationPrincipal String ownerId)
    {
        return recipeStepService.createRecipeStep(request, recipeId, Integer.parseInt(ownerId));
    }

    // Put
    @Operation(summary = "Update a recipe step", description = "Updates an existing step line on a recipe. Only the owner may modify a recipe's steps")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Step line updated successfully", content = @Content(schema = @Schema(implementation = RecipeStepResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this recipe, or the step line does not belong to the specified recipe", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found, or step not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/recipe/{recipeId}/step/{id}/edit")
    public RecipeStepResponse updateRecipeStep(@PathVariable int id, @Valid @RequestBody RecipeStepRequest request, 
        @PathVariable Integer recipeId, @AuthenticationPrincipal String ownerId)
    {
        return recipeStepService.updateRecipeStep(id, request, recipeId, Integer.parseInt(ownerId));
    }


    // Put
    @Operation(summary = "Reorder a recipe step", description = "Reassigns step numbers according to the submitted ordered list of step IDs. The submitted IDs must exactly match the recipe's existing step IDs. Only the owner may reorder a recipe's steps")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Steps reordered successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = RecipeStepResponse.class)))),
        @ApiResponse(responseCode = "400", description = "Submitted step IDs do not exactly match the recipe's existing step IDs", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this recipe", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/recipe/{recipeId}/reorder")
    public List<RecipeStepResponse> reorderSteps(@PathVariable Integer recipeId, @Valid @RequestBody RecipeStepReorderRequest request,
    @AuthenticationPrincipal String ownerId)
    {
        return recipeStepService.reorderSteps(recipeId, request, Integer.parseInt(ownerId));
    }


    // Delete
    @Operation(summary = "Delete a recipe step", description = "Removes a step from a recipe. Only the owner may modify a recipe's steps")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Step deleted successfully"),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this recipe, or the step does not belong to the specified recipe", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found, or step not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("/recipe/{recipeId}/step/{id}/delete")
    public ResponseEntity<Void> deleteRecipeStep(@PathVariable int id, @PathVariable Integer recipeId, @AuthenticationPrincipal String ownerId)
    {
        recipeStepService.deleteRecipeStep(id, recipeId, Integer.parseInt(ownerId));
        return ResponseEntity.noContent().build();
    }
}