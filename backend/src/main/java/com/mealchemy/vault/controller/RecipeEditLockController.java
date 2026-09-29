package com.mealchemy.vault.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;
import jakarta.validation.Valid;

/* Import classes */
import com.mealchemy.vault.dto.RecipeLockResponse;

import com.mealchemy.vault.service.RecipeEditLockService;

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
@RequestMapping("/recipes/{recipeId}/lock")
@Tag(name = "Recipe Edit Locks", description = "Soft edit locks for recipes shared in collaborative vaults")
public class RecipeEditLockController {

    private final RecipeEditLockService recipeEditLockService;

    public RecipeEditLockController(RecipeEditLockService recipeEditLockService)
    {
        this.recipeEditLockService = recipeEditLockService;
    }

    /* Mapping functions */

    // Get
    @Operation(summary = "Get the current edit lock on a recipe", description = "Returns the live lock on a recipe, if one exists. Caller must have access to the recipe.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "A live lock exists", content = @Content(schema = @Schema(implementation = RecipeLockResponse.class))),
        @ApiResponse(responseCode = "204", description = "No live lock on this recipe"),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("")
    public ResponseEntity<RecipeLockResponse> getLock(@PathVariable Integer recipeId, @AuthenticationPrincipal String userId)
    {
        RecipeLockResponse response = recipeEditLockService.getLock(recipeId, Integer.parseInt(userId));

        if (response == null) {
            return ResponseEntity.noContent().build();
        }

        return ResponseEntity.ok(response);
    }


    // Post
    @Operation(summary = "Acquire or refresh the edit lock on a recipe", description = "Acquires the edit lock for the caller, or refreshes it if the caller already holds it. Only the recipe owner or a vault EDITOR may acquire a lock.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Lock acquired or refreshed successfully", content = @Content(schema = @Schema(implementation = RecipeLockResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found, or the caller is not its owner or an EDITOR-role member", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "409", description = "The recipe is currently being edited by another user", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("")
    public ResponseEntity<RecipeLockResponse> acquireLock(@PathVariable Integer recipeId, @AuthenticationPrincipal String userId)
    {
        return ResponseEntity.ok(recipeEditLockService.acquireLock(recipeId, Integer.parseInt(userId)));
    }


    // Delete
    @Operation(summary = "Release the edit lock on a recipe", description = "Releases the caller's edit lock on a recipe. Only the current lock holder may release it.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Lock released successfully"),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller is not the current lock holder", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found, or no active lock exists on this recipe", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("")
    public ResponseEntity<Void> releaseLock(@PathVariable Integer recipeId, @AuthenticationPrincipal String userId)
    {
        recipeEditLockService.releaseLock(recipeId, Integer.parseInt(userId));
        return ResponseEntity.noContent().build();
    }

}