package com.mealchemy.vault.controller;
 
/* Import libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.http.HttpStatus;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
 
import java.time.OffsetDateTime;
import java.util.List;
import com.mealchemy.config.JwtUtil;
 
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
 
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.web.server.ResponseStatusException;
 
/* Import classes */
import com.mealchemy.vault.dto.VaultInvitationRequest;
import com.mealchemy.vault.dto.VaultInvitationResponse;
import com.mealchemy.vault.dto.VaultMemberResponse;
import com.mealchemy.vault.service.VaultInvitationService;
import com.mealchemy.shared.enums.InvitationStatus;
import com.mealchemy.shared.enums.VaultMemberRole;
import com.mealchemy.config.WithMockJwtUser;
 
@ExtendWith(SpringExtension.class)
@WebMvcTest(VaultInvitationController.class)
@WithMockJwtUser(userId = "1")
public class VaultInvitationControllerTest 
{

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private JwtUtil jwtUtil;
    
    @MockitoBean
    private VaultInvitationService vaultInvitationService;
    
    @Autowired
    private ObjectMapper objectMapper;

    private VaultInvitationResponse invitationResponse;
    private VaultMemberResponse memberResponse;
    private VaultInvitationRequest invitationRequest;

    @BeforeEach
    void setUp()
    {
        invitationResponse = new VaultInvitationResponse(
            10,
            5,
            "Dinner Club",
            "invitedUser@email.com",
            "owner@email.com",
            InvitationStatus.PENDING,
            OffsetDateTime.parse("2026-09-21T10:00:00Z"),
            OffsetDateTime.parse("2026-09-28T10:00:00Z"),
            null
        );
 
        memberResponse = new VaultMemberResponse(
            15,
            5,
            2,
            "invitedUser@email.com",
            OffsetDateTime.parse("2026-09-21T10:05:00Z"),
            VaultMemberRole.VIEWER
        );

        invitationRequest = new VaultInvitationRequest("invitedUser@email.com");
    }


    // ========== Create vault invitation (POST /vault/{vaultId}/invitations) ==========

    @Test
    void createVaultInvitation_withCreatedInvitation_returns200() throws Exception 
    {
        when(vaultInvitationService.createInvitation(eq(5), any(VaultInvitationRequest.class), eq(1))).thenReturn(invitationResponse);

        mockMvc.perform(post("/vault/5/invitations")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(invitationRequest)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.invitationId").value(10))
            .andExpect(jsonPath("$.vaultId").value(5))
            .andExpect(jsonPath("$.invitedEmail").value("invitedUser@email.com"))
            .andExpect(jsonPath("$.status").value("PENDING"));
    }

    @Test
    void createVaultInvitation_inviteSelf_returns400() throws Exception 
    {
        when(vaultInvitationService.createInvitation(eq(5), any(VaultInvitationRequest.class), eq(1))).thenThrow(new ResponseStatusException(HttpStatus.BAD_REQUEST, "You cannot invite yourself."));

        mockMvc.perform(post("/vault/5/invitations")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(invitationRequest)))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.message").value("You cannot invite yourself."));
    }

    @Test
    void createVaultInvitation_whenNotOwner_returns403() throws Exception 
    {
        when(vaultInvitationService.createInvitation(eq(5), any(VaultInvitationRequest.class), eq(1))).thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "You are no the vault owner."));

        mockMvc.perform(post("/vault/5/invitations")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(invitationRequest)))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value("You are no the vault owner."));
    }

    @Test
    void createVaultInvitation_emailNotRegistered_returns404() throws Exception 
    {
        when(vaultInvitationService.createInvitation(eq(5), any(VaultInvitationRequest.class), eq(1))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Email not found."));

        mockMvc.perform(post("/vault/5/invitations")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(invitationRequest)))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("Email not found."));
    }

    @Test
    void createVaultInvitation_alreadyAMember_returns409() throws Exception 
    {
        when(vaultInvitationService.createInvitation(eq(5), any(VaultInvitationRequest.class), eq(1))).thenThrow(new ResponseStatusException(HttpStatus.CONFLICT, "User is already a member of this vault."));

        mockMvc.perform(post("/vault/5/invitations")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(invitationRequest)))
            .andExpect(status().isConflict())
            .andExpect(jsonPath("$.message").value("User is already a member of this vault."));
    }


    // ========== Create all invitations for a vault (GET /vault/{vaultId}/invitations ) ==========

    @Test
    void getAllInvitationsForVault_withList_returns200() throws Exception 
    {
        when(vaultInvitationService.getVaultInvitations(5, 1)).thenReturn(List.of(invitationResponse));

        mockMvc.perform(get("/vault/5/invitations"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$[0].invitationId").value(10))
            .andExpect(jsonPath("$[0].status").value("PENDING"));
    }

    @Test
    void getAllInvitationsForVault_withEmptyList_returns200() throws Exception 
    {
        when(vaultInvitationService.getVaultInvitations(5, 1)).thenReturn(List.of());

        mockMvc.perform(get("/vault/5/invitations"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$").isArray())
            .andExpect(jsonPath("$").isEmpty());
    }
    
    @Test
    void getAllInvitationsForVault_whenNotOwner_returns403() throws Exception 
    {
        when(vaultInvitationService.getVaultInvitations(5, 1)).thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "You are no the vault owner."));

        mockMvc.perform(get("/vault/5/invitations"))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value("You are no the vault owner."));
    }

    @Test
    void getAllInvitationsForVault_VaultNotFound_returns404() throws Exception 
    {
        when(vaultInvitationService.getVaultInvitations(5, 1)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        mockMvc.perform(get("/vault/5/invitations"))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("Vault not found."));
    }


    // ========== Get logged in user's (my) invitations (GET /invitations/me ) ==========

    @Test
    void getUsersPendingVaultInvitations_withList_returns200() throws Exception 
    {
        when(vaultInvitationService.getMyPendingInvitations(1)).thenReturn(List.of(invitationResponse));

        mockMvc.perform(get("/invitations/me"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$[0].invitationId").value(10))
            .andExpect(jsonPath("$[0].status").value("PENDING"));
    }

    @Test
    void getUsersPendingVaultInvitations_withEmptyList_returns200() throws Exception 
    {
        when(vaultInvitationService.getMyPendingInvitations(1)).thenReturn(List.of());

        mockMvc.perform(get("/invitations/me"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$").isArray())
            .andExpect(jsonPath("$").isEmpty());
    }
    
    
    // ========== Accept invitation (POST /invitations/{id}/accept ) ==========

    @Test
    void acceptVaultInvitation_createsVaultMember_returns200() throws Exception 
    {
        when(vaultInvitationService.acceptInvitation(10, 1)).thenReturn(memberResponse);

        mockMvc.perform(post("/invitations/10/accept")
            .with(csrf()))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.userId").value(2))
            .andExpect(jsonPath("$.role").value("VIEWER"));
    }

    @Test
    void acceptVaultInvitation_callerNotInvitee_returns403() throws Exception 
    {
        when(vaultInvitationService.acceptInvitation(10, 1)).thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "User not intended recipient."));

        mockMvc.perform(post("/invitations/10/accept")
            .with(csrf()))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value("User not intended recipient."));
    }

    @Test
    void acceptVaultInvitation_invitationNotFound_returns404() throws Exception 
    {
        when(vaultInvitationService.acceptInvitation(10, 1)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault invitation not found."));

        mockMvc.perform(post("/invitations/10/accept")
            .with(csrf()))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("Vault invitation not found."));
    }

    @Test
    void acceptVaultInvitation_statusNotPending_returns409() throws Exception 
    {
        when(vaultInvitationService.acceptInvitation(10, 1)).thenThrow(new ResponseStatusException(HttpStatus.CONFLICT, "Invitation has the wrong status."));

        mockMvc.perform(post("/invitations/10/accept")
            .with(csrf()))
            .andExpect(status().isConflict())
            .andExpect(jsonPath("$.message").value("Invitation has the wrong status."));
    }


    // ========== Decline invitation (POST /invitations/{id}/decline ) ==========

    @Test
    void declineVaultInvitation_createsVaultMember_returns200() throws Exception 
    {
        VaultInvitationResponse declined = new VaultInvitationResponse(
            10, 
            5, 
            "Dinner Club", 
            "invitedUser@email.com", 
            "owner@email.com",
            InvitationStatus.DECLINED,
            OffsetDateTime.parse("2026-09-21T10:00:00Z"),
            OffsetDateTime.parse("2026-09-28T10:00:00Z"),
            OffsetDateTime.parse("2026-09-21T11:00:00Z")
        );

        when(vaultInvitationService.declineInvitation(10, 1)).thenReturn(declined);

        mockMvc.perform(post("/invitations/10/decline")
            .with(csrf()))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.status").value("DECLINED"));
    }

    @Test
    void declineVaultInvitation_callerNotInvitee_returns403() throws Exception 
    {
        when(vaultInvitationService.declineInvitation(10, 1)).thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "User not intended recipient."));

        mockMvc.perform(post("/invitations/10/decline")
            .with(csrf()))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value("User not intended recipient."));
    }

    @Test
    void declineVaultInvitation_invitationNotFound_returns404() throws Exception 
    {
        when(vaultInvitationService.declineInvitation(10, 1)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault invitation not found."));

        mockMvc.perform(post("/invitations/10/decline")
            .with(csrf()))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("Vault invitation not found."));
    }

    @Test
    void declineVaultInvitation_statusNotPending_returns409() throws Exception 
    {
        when(vaultInvitationService.declineInvitation(10, 1)).thenThrow(new ResponseStatusException(HttpStatus.CONFLICT, "Invitation has the wrong status."));

        mockMvc.perform(post("/invitations/10/decline")
            .with(csrf()))
            .andExpect(status().isConflict())
            .andExpect(jsonPath("$.message").value("Invitation has the wrong status."));
    }


    // ========== Cancel invitation (DELETE /invitations/{id} ) ==========

    @Test
    void cancelVaultInvitation_returns204() throws Exception
    {
        doNothing().when(vaultInvitationService).cancelInvitation(10, 1);
 
        mockMvc.perform(delete("/invitations/10").with(csrf()))
            .andExpect(status().isNoContent());
    }
 
    @Test
    void cancelVaultInvitation_returns403_whenNotOwner() throws Exception
    {
        doThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "You are not the Vault owner.")).when(vaultInvitationService).cancelInvitation(10, 1);
 
        mockMvc.perform(delete("/invitations/10").with(csrf()))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value("You are not the Vault owner."));
    }
}