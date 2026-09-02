package com.mealchemy.vault.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;
import jakarta.validation.Valid;

/* Import classes */
import com.mealchemy.vault.dto.VaultFolderRequest;
import com.mealchemy.vault.dto.VaultFolderResponse;
import com.mealchemy.vault.service.VaultFolderService;


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
@RequestMapping("/folders")
@Tag(name = "Vault Folders", description = "Folders within a vault")
public class VaultFolderController
{
    private final VaultFolderService vaultFolderService;

    public VaultFolderController(VaultFolderService vaultFolderService)
    {
        this.vaultFolderService = vaultFolderService;
    }    

    /* Mapping Functions */

    // Get
    @Operation(summary = "Get the authenticated user's private valut folders", description = "Returns all folders within the authenticated user's private vault.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Folders retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = VaultFolderResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Private vault not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/vault/private")
    public List<VaultFolderResponse> getPrivateVaultFolders(@AuthenticationPrincipal String userId)
    {
        return vaultFolderService.getPrivateVaultFolders(Integer.parseInt(userId));
    }


    // Get
    @Operation(summary = "Get all folders for a vault", description = "Returns all folders within a specific vault. Caller must be the specified vault's owner or a member.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Folders retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = VaultFolderResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller is not the owner or a member of this vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Vault not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/vault/{vaultId}")
    public List<VaultFolderResponse> getVaultFolderByVaultId(@PathVariable int vaultId, @AuthenticationPrincipal String userId)
    {
        return vaultFolderService.getVaultFolderByVaultId(vaultId, Integer.parseInt(userId));
    }


    // Get
    @Operation(summary = "Get a folder by name", description = "Returns a folder matching the given name. Caller must be the specified vault's owner or a member.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Folder retrieved successfully", content = @Content(schema = @Schema(implementation = VaultFolderResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller is not the owner or a member of the specified vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Vault not found, ot no folder matches the given name", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/{vaultId}/folder/name/{name}")
    public VaultFolderResponse getVaultFolderByName(@PathVariable String name, @PathVariable Integer vaultId, @AuthenticationPrincipal String userId)
    {
        return vaultFolderService.getVaultFolderByName(name, vaultId, Integer.parseInt(userId));
    }


    // Get
    @Operation(summary = "Get a folder by ID", description = "Returns a folder by its ID. Caller must be the specified vault's owner or a member.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Folder retrieved successfully", content = @Content(schema = @Schema(implementation = VaultFolderResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller is not the owner or a member of the specified vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Vault not found, or no folder matches the given name", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/{vaultId}/folder/{id}")
    public VaultFolderResponse getVaultFolderById(@PathVariable int id, @PathVariable Integer vaultId, @AuthenticationPrincipal String userId)
    {
        return vaultFolderService.getVaultFolderById(id, vaultId, Integer.parseInt(userId));
    }


    // Post
    @Operation(summary = "Create a vault folder", description = "Creates a new folder in a vault. Only the vault owner may create folders.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Folder created successfully", content = @Content(schema = @Schema(implementation = VaultFolderResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own the specified vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Vault not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping
    public VaultFolderResponse createVaultFolder(@Valid @RequestBody VaultFolderRequest request, @AuthenticationPrincipal String ownerId)
    {
        return vaultFolderService.createVaultFolder(request, Integer.parseInt(ownerId));
    }


    // Put
    @Operation(summary = "Update a vault folder", description = "Updates a folder's vault and/or name. Only the vault owner may modify folders.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Folder updated successfully", content = @Content(schema = @Schema(implementation = VaultFolderResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own the specified vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Vault not found, or folder not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/{id}")
    public VaultFolderResponse updateVaultFolder(@PathVariable int id, @Valid @RequestBody VaultFolderRequest request, @AuthenticationPrincipal String ownerId)
    {
        return vaultFolderService.updateVaultFolder(id, request, Integer.parseInt(ownerId));
    }


    // Delete
    @Operation(summary = "Delete a vault folder", description = "Deletes a folder from a vault. Only the vault owner may delete folders.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Folder deleted successfully"),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own the specified vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Vault not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("/vault/{vaultId}/folder/{id}")
    public ResponseEntity<Void> deleteVaultFolder(@PathVariable int id, @PathVariable Integer vaultId, @AuthenticationPrincipal String ownerId)
    {
        vaultFolderService.deleteVaultFolder(id, vaultId, Integer.parseInt(ownerId));
        return ResponseEntity.noContent().build();
    }
}