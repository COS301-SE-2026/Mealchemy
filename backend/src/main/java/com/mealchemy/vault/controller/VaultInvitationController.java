package com.mealchemy.vault.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;
import jakarta.validation.Valid;

/* Import classes */
import com.mealchemy.vault.dto.VaultInvitationResponse;
import com.mealchemy.vault.dto.VaultMemberResponse;
import com.mealchemy.vault.dto.VaultInvitationRequest;

import com.mealchemy.vault.service.VaultInvitationService;

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
@Tag(name = "Vault Invitations", description = "Invitation lifecycle for shared vaults: create, list, accept, decline, cancel")
public class VaultInvitationController {

    private final VaultInvitationService vaultInvitationService;

    public VaultInvitationController(VaultInvitationService vaultInvitationService)
    {
        this.vaultInvitationService = vaultInvitationService;
    }

    /* Mapping functions */

    // Post
    @Operation(summary = "Invite a user to a shared vault", description = "Creates a PENDING invitation for a registered user, by email, to join a shared vault. Only the vault owner can send invitations and only for SHARED vaults. Fails if user is already a member, has a pending invitation or is the owner.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Invitation created successfully", content = @Content(schema = @Schema(implementation = VaultInvitationResponse.class))),
        @ApiResponse(responseCode = "400", description = "Owner attempted to invite themself", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this vault, or the vault is not SHARED", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Vault not found, or no user registered with the given email", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "409", description = "User is already a member or has a PENDING invite for this vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/vault/{vaultId}/invitations")
    public ResponseEntity<VaultInvitationResponse> createVaultInvitation(@PathVariable Integer vaultId, @Valid @RequestBody VaultInvitationRequest request, @AuthenticationPrincipal String ownerId)
    {
        return ResponseEntity.ok(vaultInvitationService.createInvitation(vaultId, request, Integer.parseInt(ownerId)));
    }


    // Get
    @Operation(summary = "Get all invitations sent for a vault", description = "Returns every invitation ever sent for a vault, of any status (pending, accepted, declined, cancelled, expired). The caller must be the vault owner.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Invitations retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = VaultInvitationResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Vault not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/vault/{vaultId}/invitations")
    public ResponseEntity<List<VaultInvitationResponse>> getAllInvitationsForVault(@PathVariable Integer vaultId, @AuthenticationPrincipal String ownerId)
    {
        return ResponseEntity.ok(vaultInvitationService.getVaultInvitations(vaultId, Integer.parseInt(ownerId)));
    }


    // Get
    @Operation(summary = "Get my (user's) pending vault invitations", description = "Returns all PENDING invitations addressed to the authenticated user, across all SHARED vaults.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pending invitations retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = VaultInvitationResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/invitations/me")
    public ResponseEntity<List<VaultInvitationResponse>> getMyPendingVaultInvitations(@AuthenticationPrincipal String userId)
    {
        return ResponseEntity.ok(vaultInvitationService.getMyPendingInvitations(Integer.parseInt(userId)));
    }


    // Post
    @Operation(summary = "Accept a vault invitation", description = "Accepts a PENDING invitation addressed to the caller - creates a VaultMember with the default role VIEWER and marks the invitation as ACCEPTED. Caller must be the invitee.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Invitation accepted, membership created", content = @Content(schema = @Schema(implementation = VaultMemberResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller is not the invited user", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Invitation not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "409", description = "Invitation is not PENDING", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),        
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/invitations/{invitationId}/accept")
    public ResponseEntity<VaultMemberResponse> acceptVaultInvitation(@PathVariable Integer invitationId, @AuthenticationPrincipal String userId)
    {
        return ResponseEntity.ok(vaultInvitationService.acceptInvitation(invitationId, Integer.parseInt(userId)));
    }


    // Post
    @Operation(summary = "Decline a vault invitation", description = "Declines a PENDING invitation addressed to the caller - marks the invitation as DECLINED. Caller must be the invitee.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Invitation declined", content = @Content(schema = @Schema(implementation = VaultInvitationResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller is not the invited user", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Invitation not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "409", description = "Invitation is not PENDING", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),        
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/invitations/{invitationId}/decline")
    public ResponseEntity<VaultInvitationResponse> declineVaultInvitation(@PathVariable Integer invitationId, @AuthenticationPrincipal String userId)
    {
        return ResponseEntity.ok(vaultInvitationService.declineInvitation(invitationId, Integer.parseInt(userId)));
    }


    // Delete
    @Operation(summary = "Cancel a PENDING vault invitation", description = "Cancels a PENDING invitation - marks the invitation as CANCELLED. Only the vault owner can cancel the invitation.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Invitation cancelled successfully"),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own the vault", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Invitation not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "409", description = "Invitation is not PENDING", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),        
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("/invitations/{invitationId}")
    public ResponseEntity<Void> cancelVaultInvitation(@PathVariable Integer invitationId, @AuthenticationPrincipal String ownerId)
    {
        vaultInvitationService.cancelInvitation(invitationId, Integer.parseInt(ownerId));
        return ResponseEntity.noContent().build();
    }
}