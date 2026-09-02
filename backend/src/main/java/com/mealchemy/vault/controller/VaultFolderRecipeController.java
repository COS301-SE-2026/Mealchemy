package com.mealchemy.vault.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;
import jakarta.validation.Valid;

/* Import classes */
import com.mealchemy.vault.dto.VaultFolderRecipeRequest;
import com.mealchemy.vault.dto.VaultFolderRecipeResponse;
import com.mealchemy.vault.dto.VaultFolderRecipeMoveRequest;
import com.mealchemy.vault.service.VaultFolderRecipeService;

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
@RequestMapping("/recipefolders")
@Tag(name = "Vault Folder Recipes", description = "Associations linking recipes to folders within a vault.")
public class VaultFolderRecipeController
{
    private final VaultFolderRecipeService vaultFolderRecipeService;

    public VaultFolderRecipeController(VaultFolderRecipeService vaultFolderRecipeService)
    {
        this.vaultFolderRecipeService = vaultFolderRecipeService;
    }

    /* Mapping Functions */

    // Get
    @Operation(summary = "Get all recipes in a folder", description = "Returns all recipes associations for a specific folder. Caller must be the folder's vault owner or a member.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Recipe associations retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = VaultFolderRecipeResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller is not the owner or a member of the folder's vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Folder not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/recipes/{folderId}")
    public List<VaultFolderRecipeResponse> getRecipesByFolderId(@PathVariable int folderId, @AuthenticationPrincipal String userId)
    {
        return vaultFolderRecipeService.getRecipesByFolderId(folderId, Integer.parseInt(userId));
    }


    // Get
    @Operation(summary = "Get all folders containing a recipe", description = "Returns every folder association for a recipe. Only the recipe's owner may view this.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Recipe associations retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = VaultFolderRecipeResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this recipe", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/folders/{recipeId}")
    public List<VaultFolderRecipeResponse> getFoldersByRecipeId(@PathVariable int recipeId, @AuthenticationPrincipal String userId)
    {
        return vaultFolderRecipeService.getFoldersByRecipeId(recipeId, Integer.parseInt(userId));
    }


    // Get
    @Operation(summary = "Get a folder recipe-association by ID", description = "Returns a single folder-recipe association. Caller must be the associated vault's owner or a member.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Association retrieved successfully", content = @Content(schema = @Schema(implementation = VaultFolderRecipeResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller is not the owner or a member of the associated vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Association not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/{id}")
    public VaultFolderRecipeResponse getFolderRecipeById(@PathVariable int id, @AuthenticationPrincipal String userId)
    {
        return vaultFolderRecipeService.getFolderRecipeById(id, Integer.parseInt(userId));
    }


    // Post
    @Operation(summary = "Add a recipe to a folder", description = "Creates an association linking a recipe to a folder. Caller must be the folder's vault owner or a member.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Recipe added to folder successfully", content = @Content(schema = @Schema(implementation = VaultFolderRecipeResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller is not the owner or a member of the folder's vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Folder not found, recipe not found, or authenticated user not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/folder/{folderId}")
    public VaultFolderRecipeResponse createVaultFolderRecipe(@Valid @RequestBody VaultFolderRecipeRequest request, @AuthenticationPrincipal String userId, @PathVariable Integer folderId)
    {
        return vaultFolderRecipeService.createVaultFolderRecipe(request, Integer.parseInt(userId), folderId);
    }


    // Put
    @Operation(summary = "Move a recipe to a different folder", description = "Moves a recipe association to a different folder within the same vault. Only the vault owner may move associations.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Association moved successfully", content = @Content(schema = @Schema(implementation = VaultFolderRecipeResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own the vault, or the target folder is in a different vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Association not found, or target folder not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/{id}")
    public VaultFolderRecipeResponse updateVaultFolderRecipe(@PathVariable int id, @Valid @RequestBody VaultFolderRecipeMoveRequest request, @AuthenticationPrincipal String userId)
    {
        return vaultFolderRecipeService.updateVaultFolderRecipe(id, request, Integer.parseInt(userId));
    }


    // Delete
    @Operation(summary = "Removes a recipe from a folder", description = "Deletes a folder-recipe association. Allowed for the vault owner, or the member who originally added it.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Association deleted successfully"),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller is not the vault owner or the member who added this association", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Association not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteVaultFolderRecipe(@PathVariable int id, @AuthenticationPrincipal String userId)
    {
        vaultFolderRecipeService.deleteVaultFolderRecipe(id, Integer.parseInt(userId));
        return ResponseEntity.noContent().build();
    }
}