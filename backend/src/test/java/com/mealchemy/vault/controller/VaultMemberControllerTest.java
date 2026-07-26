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
import com.mealchemy.vault.service.VaultMemberService;
import com.mealchemy.config.WithMockJwtUser;

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

    @BeforeEach
    void setUp()
    {
        response = new VaultMemberResponse(1, 1, 2, OffsetDateTime.now());

        request = new VaultMemberRequest("testUser@gmail.com");
    }

    @Test
    void getVaultMembersByVaultId_returns200_withList() throws Exception
    {
        when(vaultMemberService.getVaultMembersByVaultId(1, 1)).thenReturn(List.of(response));

        mockMvc.perform(get("/vault/1/members/all")).andExpect(status().isOk()).andExpect(jsonPath("$[0].userId").value(2));
    }

    @Test
    void getVaultMembersByVaultId_returns403_whenNotOwnerOrMember() throws Exception
    {
        when(vaultMemberService.getVaultMembersByVaultId(1, 1))
            .thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "Only a member/owner of the vault can view its members."));

        mockMvc.perform(get("/vault/1/members/all")).andExpect(status().isForbidden()).andExpect(jsonPath("$.message").value("Only a member/owner of the vault can view its members."));
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
    void removeVaultMember_returns200() throws Exception
    {
        doNothing().when(vaultMemberService).removeVaultMember(eq(1), any(VaultMemberRequest.class), eq(1));

        mockMvc.perform(delete("/vault/1/members/delete")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk());
    }

    @Test
    void removeVaultMember_returns404_whenMemberRowNotFound() throws Exception
    {
        doThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "VaultMember row not found."))
            .when(vaultMemberService).removeVaultMember(eq(1), any(VaultMemberRequest.class), eq(1));

        mockMvc.perform(delete("/vault/1/members/delete")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("VaultMember row not found."));
    }
}