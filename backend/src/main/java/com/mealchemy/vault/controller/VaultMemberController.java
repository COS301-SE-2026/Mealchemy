package com.mealchemy.vault.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;
import jakarta.validation.Valid;

/* Import classes */
import com.mealchemy.vault.dto.VaultMemberResponse;
import com.mealchemy.vault.dto.VaultMemberRoleRequest;
import com.mealchemy.vault.service.VaultMemberService;

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
@RequestMapping("/vault")
@Tag(name = "Vault Members", description = "Membership management for shared vaults")
public class VaultMemberController {
    private final VaultMemberService vaultMemberService;

    public VaultMemberController(VaultMemberService vaultMemberService)
    {
        this.vaultMemberService = vaultMemberService;
    }

    /* Mapping functions */

    // Get
    @Operation(summary = "Get all members of a vault", description = "Returns all members of a vault. Caller must be the vault's owner or a member.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Members retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = VaultMemberResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Vault not found, or the caller is not its owner or a member", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/{vaultId}/members/all")
    public List<VaultMemberResponse> getVaultMembersByVaultId(@PathVariable Integer vaultId, @AuthenticationPrincipal String userId)
    {
        return vaultMemberService.getVaultMembersByVaultId(vaultId, Integer.parseInt(userId));
    }

    // Delete
    @Operation(summary = "Removes a member from a vault", description = "Removes a member from a shared vault by email. Only the vault owner may remove members.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Member removed successfully"),
        @ApiResponse(responseCode = "400", description = "Unable to remove member", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Vault not found, or not owned by the caller", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("/{vaultId}/members/{userId}")
    public ResponseEntity<Void> removeVaultMember(@PathVariable Integer vaultId, @PathVariable Integer userId, @AuthenticationPrincipal String ownerId)
    {
        vaultMemberService.removeVaultMember(vaultId, userId, Integer.parseInt(ownerId));
        return ResponseEntity.noContent().build();
    }

    // Patch
    @Operation(summary = "Change a vault member's role", description = "Changes a shared vault member's role between VIEWER and EDITOR. Only the vault owner may change roles. OWNER cannot be set as a target role.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Role changed successfully", content = @Content(schema = @Schema(implementation = VaultMemberResponse.class))),
        @ApiResponse(responseCode = "400", description = "Request attempted to set role to OWNER", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Vault not found, or target user is not a member of this vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PatchMapping("/{vaultId}/members/{userId}/role") 
    public VaultMemberResponse changeRole(@PathVariable Integer vaultId, @PathVariable Integer userId, @Valid @RequestBody VaultMemberRoleRequest request, @AuthenticationPrincipal String ownerId)
    {
        return vaultMemberService.changeRole(vaultId, userId, request, Integer.parseInt(ownerId));
    }
}
