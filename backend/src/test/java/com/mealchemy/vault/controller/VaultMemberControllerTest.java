package com.mealchemy.vault.controller;

/* Import libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.security.test.context.support.WithMockUser;
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
import org.springframework.http.HttpStatus;

/* Import classes */
import com.mealchemy.vault.dto.VaultMemberRequest;
import com.mealchemy.vault.dto.VaultMemberResponse;
import com.mealchemy.vault.dto.VaultMemberRoleRequest;
import com.mealchemy.vault.service.VaultMemberService;
import com.mealchemy.config.WithMockJwtUser;

import com.mealchemy.shared.enums.VaultMemberRole;

@ExtendWith(SpringExtension.class)
@WebMvcTest(VaultMemberController.class)
@WithMockJwtUser(userId = "1")
public class VaultMemberControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @MockitoBean 
    private JwtUtil jwtUtil;

    @MockitoBean
    private VaultMemberService vaultMemberService;

    @Autowired
    private ObjectMapper objectMapper;

    private VaultMemberResponse response;
    private VaultMemberRequest request;
    private VaultMemberRoleRequest roleRequest;

    @BeforeEach
    void setUp()
    {
        response = new VaultMemberResponse(1, 1, 2, "testUser@gmail.com", OffsetDateTime.now(), VaultMemberRole.EDITOR);

        request = new VaultMemberRequest("testUser@gmail.com");

        roleRequest = new VaultMemberRoleRequest(VaultMemberRole.EDITOR);
    }

    @Test
    void getVaultMembersByVaultId_returns200_withList() throws Exception
    {
        when(vaultMemberService.getVaultMembersByVaultId(1, 1)).thenReturn(List.of(response));

        mockMvc.perform(get("/vault/1/members/all")).andExpect(status().isOk()).andExpect(jsonPath("$[0].userId").value(2));
    }

    @Test
    void getVaultMembersByVaultId_returns404_whenNotOwnerOrMember() throws Exception
    {
        when(vaultMemberService.getVaultMembersByVaultId(1, 1))
            .thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        mockMvc.perform(get("/vault/1/members/all")).andExpect(status().isNotFound()).andExpect(jsonPath("$.message").value("Vault not found."));
    }

    @Test
    void addVaultMember_returns200_withCreatedMember() throws Exception
    {
        when(vaultMemberService.addVaultMember(eq(1), any(VaultMemberRequest.class), eq(1))).thenReturn(response);

        mockMvc.perform(post("/vault/1/members/create")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.userId").value(2));
    }

    @Test
    void addVaultMember_returns400_whenEmailBlank() throws Exception
    {
        VaultMemberRequest invalidRequest = new VaultMemberRequest("");

        mockMvc.perform(post("/vault/1/members/create")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(invalidRequest)))
            .andExpect(status().isBadRequest());
    }

    @Test
    void addVaultMember_returns403_whenVaultIsPrivate() throws Exception
    {
        when(vaultMemberService.addVaultMember(eq(1), any(VaultMemberRequest.class), eq(1)))
            .thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "Members can't be added to a private vault."));

        mockMvc.perform(post("/vault/1/members/create")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value("Members can't be added to a private vault."));
    }

    @Test
    void removeVaultMember_returns204() throws Exception
    {
        doNothing().when(vaultMemberService).removeVaultMember(1, 2, 1);

        mockMvc.perform(delete("/vault/1/members/2").with(csrf()))
            .andExpect(status().isNoContent());
    }

    @Test
    void removeVaultMember_returns400_whenMemberRowNotFound() throws Exception
    {
        doThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "VaultMember row not found."))
            .when(vaultMemberService).removeVaultMember(1, 2, 1);

        mockMvc.perform(delete("/vault/1/members/2").with(csrf()))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("VaultMember row not found."));
    }

    @Test
void changeRole_returns200_withUpdatedMember() throws Exception
{
    when(vaultMemberService.changeRole(eq(1), eq(2), any(VaultMemberRoleRequest.class), eq(1))).thenReturn(response);

    mockMvc.perform(patch("/vault/1/members/2/role")
        .with(csrf())
        .contentType(MediaType.APPLICATION_JSON)
        .content(objectMapper.writeValueAsString(roleRequest)))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.userId").value(2));
}

@Test
void changeRole_returns400_whenSettingOwner() throws Exception
{
    VaultMemberRoleRequest ownerRequest = new VaultMemberRoleRequest(VaultMemberRole.OWNER);

    when(vaultMemberService.changeRole(eq(1), eq(2), any(VaultMemberRoleRequest.class), eq(1)))
        .thenThrow(new ResponseStatusException(HttpStatus.BAD_REQUEST, "Only one owner per vault."));

    mockMvc.perform(patch("/vault/1/members/2/role")
        .with(csrf())
        .contentType(MediaType.APPLICATION_JSON)
        .content(objectMapper.writeValueAsString(ownerRequest)))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.message").value("Only one owner per vault."));
}

@Test
void changeRole_returns403_whenNotOwner() throws Exception
{
    when(vaultMemberService.changeRole(eq(1), eq(2), any(VaultMemberRoleRequest.class), eq(1)))
        .thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of the vault can change a member's role."));

    mockMvc.perform(patch("/vault/1/members/2/role")
        .with(csrf())
        .contentType(MediaType.APPLICATION_JSON)
        .content(objectMapper.writeValueAsString(roleRequest)))
        .andExpect(status().isForbidden())
        .andExpect(jsonPath("$.message").value("Only the owner of the vault can change a member's role."));
}

}