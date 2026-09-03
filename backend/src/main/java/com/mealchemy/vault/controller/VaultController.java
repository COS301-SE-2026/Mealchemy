package com.mealchemy.vault.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.List;
import jakarta.validation.Valid;

/* Import classes */
import com.mealchemy.vault.dto.VaultResponse;
import com.mealchemy.vault.dto.VaultRequest;
import com.mealchemy.vault.service.VaultService;

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
@RequestMapping("/vaults")
@Tag(name = "Vaults", description = "Private, shared, and global recipe vaults")
public class VaultController
{
    private final VaultService vaultService;

    public VaultController(VaultService vaultService)
    {
        this.vaultService = vaultService;
    }

    /* Mapping Functions */

    // Get
    @Operation(summary = "Get all vaults owned by the authenticated user", description = "Returns every vault the authenticated user owns.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Vaults retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = VaultResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/owner/vaults")
    public List<VaultResponse> getVaultsByOwnerId(@AuthenticationPrincipal String ownerId)
    {
        int ownerIdInt = Integer.parseInt(ownerId); 
        return vaultService.getVaultsByOwnerId(ownerIdInt);
    }


    // Get
    @Operation(summary = "Get a single vault by ID", description = "Returns a vault if he authenticated user is its owner or a member.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Vault retrieved successfully", content = @Content(schema = @Schema(implementation = VaultResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller is not the owner or a member of this vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Vault not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/{id}")
    public VaultResponse getVault(@PathVariable int id, @AuthenticationPrincipal String userId)
    {
        return vaultService.getVault(id, Integer.parseInt(userId));
    }


    // Get
    @Operation(summary = "Get all vaults accessible to the user", description = "Returns every vault the authenticated user owns or is a member of.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Accessible vaults retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = VaultResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/accessible")
    public List<VaultResponse> getAccessibleVaults(@AuthenticationPrincipal String userId)
    {
        return vaultService.getAccessibleVaults(Integer.parseInt(userId));
    }


    // Post
    @Operation(summary = "Create a vault", description = "Creates a new shared or global vault for the authenticated user. Private vaults cannot be created here - every user is given exactly one private vault at registration.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Vault created successfully", content = @Content(schema = @Schema(implementation = VaultResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Requested vaultTpe is PRIVATE, which is not allowed", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Authenticated user not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping
    public VaultResponse createVault(@Valid @RequestBody VaultRequest request, @AuthenticationPrincipal String userId)
    {
        return vaultService.createVault(request, Integer.parseInt(userId));
    }


    // Put
    @Operation(summary = "Update a vault", description = "Updates a vaults type and name. Only the owner may edit a vault, and it cannot be changed to type PRIVATE.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Vault updated successfully", content = @Content(schema = @Schema(implementation = VaultResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this vault, or requested vaultTpe is PRIVATE, which is not allowed", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Vault not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/{id}")
    public VaultResponse updateVault(@PathVariable int id, @Valid @RequestBody VaultRequest request, @AuthenticationPrincipal String ownerId)
    {
        return vaultService.updateVault(id, request, Integer.parseInt(ownerId));
    }


    // Delete
    @Operation(summary = "Delete a vault", description = "Deletes a shared vault owned by the authenticated user. Private and global vaults cannot be deleted.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Vault deleted successfully"),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this vault, or the vault is PRIVATE and cannot be deleted", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Vault not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteVault(@PathVariable int id, @AuthenticationPrincipal String ownerId)
    {
        vaultService.deleteVault(id, Integer.parseInt(ownerId));
        return ResponseEntity.noContent().build();
    }
}