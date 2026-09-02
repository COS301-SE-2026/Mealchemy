package com.mealchemy.recipe.controller;

/* Import libraries */

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;
import jakarta.validation.Valid;

/* Import classes */

import com.mealchemy.recipe.dto.RecipeRequest;
import com.mealchemy.recipe.dto.RecipeFullRequest;
import com.mealchemy.recipe.dto.RecipeUpdateRequest;
import com.mealchemy.recipe.dto.RecipePhotoUploadRequest;
import com.mealchemy.recipe.dto.RecipePhotoUploadResponse;
import com.mealchemy.recipe.dto.RecipeResponse;
import com.mealchemy.recipe.service.RecipePhotoService;
import com.mealchemy.recipe.service.RecipeService;

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
@RequestMapping("/recipes")
@Tag(name = "Recipes", description = "Recipe creation, browsing, editing, and deletion")
public class RecipeController
{
    private final RecipeService recipeService;
    private final RecipePhotoService recipePhotoService;

    public RecipeController(RecipeService recipeService, RecipePhotoService recipePhotoService)
    {
        this.recipeService = recipeService;
        this.recipePhotoService = recipePhotoService;
    }

    /* Mapping functions */

    // Get
    // changed to receive the authenticated user ID
    // swagger comments
    @Operation(summary = "Get all the recipes accessible to the user", description = "Returns every recipe that the authenticated user owns or has access to via a shared/global vault.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Recipes retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = RecipeResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/all")
    public List<RecipeResponse> getAllRecipes(@AuthenticationPrincipal String userId)
    {
        return recipeService.getAllRecipes(Integer.parseInt(userId));
    }


    @Operation(summary = "Get all community published recipes", description = "Returns every recipe marked as community published (visible in the global).")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Community recipes retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = RecipeResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/community")
    public List<RecipeResponse> getAllCommunityPublishedRecipes()
    {
        return recipeService.getAllCommunityPublishedRecipes();
    }


    // Get
    // changed to receive the authenticated user ID
    @Operation(summary = "Get a single recipe by ID", description = "Returns a recipe if it exists and is accessible to the authenticated user.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Recipe retrieved successfully", content = @Content(schema = @Schema(implementation = RecipeResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Recipe exists but is not accessible to the authenticated user", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/single/{id}")
    public RecipeResponse getRecipeById(@PathVariable Integer id, @AuthenticationPrincipal String userId)
    {
        return recipeService.getRecipeById(id, Integer.parseInt(userId));
    }


    // Post
    @Operation(summary = "Create a bare recipe", description = "Creates a recipe with no ingredients, or steps and links it to a folder in the caller's private vault.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Recipe created successfully", content = @Content(schema = @Schema(implementation = RecipeResponse.class))),
        @ApiResponse(responseCode = "400", description = "Folder ID missing, or cuisine type is invalid", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Folder is not in the caller's private vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Folder not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/create")
    public RecipeResponse createRecipe(@Valid @RequestBody RecipeRequest request, @AuthenticationPrincipal String ownerId)
    {
        return recipeService.createRecipe(request, Integer.parseInt(ownerId));
    }

    // Post
    @Operation(summary = "Create a full recipe, optionally copied from a source recipe", description = "Creates a recipe including ingredients and steps, and links it to a folder in the caller's private vault. If the sourceId refers to an existing recipe, the new recipe records it as its parent.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Recipe created successfully", content = @Content(schema = @Schema(implementation = RecipeResponse.class))),
        @ApiResponse(responseCode = "400", description = "Cuisine type is invalid, or one of the supplied ingredients does not exist in the catalogue", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Folder is not in the caller's private vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Folder not found, or source recipe not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/{sourceId}/copy")
    public RecipeResponse createFromFullRecipe(@Valid @RequestBody RecipeFullRequest request, @AuthenticationPrincipal String ownerId, @PathVariable Integer sourceId)
    {
        return recipeService.createFromFullRecipe(request, Integer.parseInt(ownerId), sourceId);
    }

    // Post
    // gets recipe id from path, validates reuqest dto, gets authenticated user id, returns signed upload info.
    @Operation(summary = "Create a signed photo upload URL for a recipe", description = "Returns signed upload details the client can use to upload a recipe photo directly to storage.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Upload URL created successfully", content = @Content(schema = @Schema(implementation = RecipePhotoUploadResponse.class))),
        @ApiResponse(responseCode = "400", description = "Validation failed on the upload request", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this recipe", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "503", description = "Recipe photo storage is not configured, or the storage provider failed to generate an upload URL", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/{id}/photo-upload-url")
    public RecipePhotoUploadResponse createPhotoUploadUrl(
        @PathVariable Integer id,
        @Valid @RequestBody RecipePhotoUploadRequest request,
        @AuthenticationPrincipal String ownerId
    )
    {
        return recipePhotoService.createPhotoUploadUrl(
            id,
            request,
            Integer.parseInt(ownerId)
        );
    }


    // Put
    @Operation(summary = "Update a recipe", description = "Update a recipe's fields, optionally replacing its ingredients and/or steps entirely. Only the owner may edit.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Recipe updated successfully", content = @Content(schema = @Schema(implementation = RecipeResponse.class))),
        @ApiResponse(responseCode = "400", description = "Cuisine type is invalid, photo removal conflicts with a supplied photo URL, photo URL is blank, or an ingredient does not exist in the catalogue", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this recipe", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/edit/{id}")
    public RecipeResponse updateRecipe(@PathVariable int id, @Valid @RequestBody RecipeUpdateRequest request, @AuthenticationPrincipal String ownerId)
    {
        return recipeService.updateRecipe(id, request, Integer.parseInt(ownerId));
    }

    // Delete
    @Operation(summary = "Delete a recipe", description = "Deletes a recipe. Only the owner may delete it.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Recipe deleted successfully"),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this recipe", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<Void> deleteRecipe(@PathVariable int id, @AuthenticationPrincipal String ownerId)
    {
        recipeService.deleteRecipe(id, Integer.parseInt(ownerId));
        return ResponseEntity.noContent().build();
    }
}
