package com.mealchemy.vault.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;
import jakarta.validation.Valid;

/* Import classes */
import com.mealchemy.vault.dto.VaultMemberResponse;
import com.mealchemy.vault.dto.VaultMemberRequest;
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
        @ApiResponse(responseCode = "404", description = "Vault not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/{vaultId}/members/all")
    public List<VaultMemberResponse> getVaultMembersByVaultId(@PathVariable Integer vaultId, @AuthenticationPrincipal String userId)
    {
        return vaultMemberService.getVaultMembersByVaultId(vaultId, Integer.parseInt(userId));
    }


    // Post
    @Operation(summary = "Add a member to a vault", description = "Adds a registered user to a shared vault by email. Only the vault owner may add members. Memebers cannot be added to a private vault.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Member added successfully", content = @Content(schema = @Schema(implementation = VaultMemberResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this vault, or the vault is PRIVATE", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Vault not found, or no user is registed with the given email", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/{vaultId}/members/create")
    public VaultMemberResponse addVaultMember(@PathVariable Integer vaultId, @Valid @RequestBody VaultMemberRequest request,
        @AuthenticationPrincipal String ownerId)
    {
        return vaultMemberService.addVaultMember(vaultId, request, Integer.parseInt(ownerId));
    }


    // Delete
    @Operation(summary = "Removes a member from a vault", description = "Removes a member from a shared vault by email. Only the vault owner may remove members.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Member removed successfully"),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Vault not found, or no user is registed with the given email, or the user is not a member of this vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("/{vaultId}/members/delete")
    public ResponseEntity<Void> removeVaultMember(@PathVariable Integer vaultId, @Valid @RequestBody VaultMemberRequest request, @AuthenticationPrincipal String ownerId)
    {
        vaultMemberService.removeVaultMember(vaultId, request, Integer.parseInt(ownerId));
        return ResponseEntity.noContent().build();
    }
}
