package com.mealchemy.vault.controller;

/* Importing libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.OffsetDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.junit.jupiter.api.Assertions.assertTrue;
import jakarta.servlet.ServletException;
import com.mealchemy.config.JwtUtil;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import org.springframework.security.test.context.support.WithMockUser;

/* Importing classes */
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.vault.dto.VaultRequest;
import com.mealchemy.vault.dto.VaultResponse;
import com.mealchemy.vault.service.VaultService;
import com.mealchemy.shared.enums.VaultType;

@WithMockUser
@WebMvcTest(VaultController.class)
public class VaultControllerTest
{
    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private VaultService vaultService;

    @MockBean
    private JwtUtil jwtUtil;

    @Autowired
    private ObjectMapper objectMapper;

    private VaultResponse response;
    private VaultRequest request;

    @BeforeEach
    void setUp()
    {
        response = new VaultResponse();
        response.setVaultId(1);
        response.setOwnerId(1);
        response.setVaultType(VaultType.PRIVATE);
        response.setName("Test Vault");
        response.setCreatedAt(OffsetDateTime.now());

        request = new VaultRequest();
        request.setOwnerId(1);
        request.setVaultType(VaultType.PRIVATE);
        request.setName("Test Vault");
    }

    // GET /vaults/owner/{ownerId}
    @Test
    void getVaultsByOwnerId_returns200_withList() throws Exception
    {
        when(vaultService.getVaultsByOwnerId(1)).thenReturn(List.of(response));

        mockMvc.perform(get("/vaults/owner/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].name").value("Test Vault"));
    }

    @Test
    void getVaultsByOwnerId_returns200_withEmptyList() throws Exception
    {
        when(vaultService.getVaultsByOwnerId(99)).thenReturn(List.of());

        mockMvc.perform(get("/vaults/owner/99"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isEmpty());
    }

    // GET /vaults/{id}
    @Test
    void getVault_returns200_whenFound() throws Exception
    {
        when(vaultService.getVault(1)).thenReturn(response);

        mockMvc.perform(get("/vaults/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Test Vault"));
    }

    @Test
    void getVault_returns500_whenNotFound() throws Exception
    {
        when(vaultService.getVault(99)).thenThrow(new RuntimeException("Vault not found."));

        mockMvc.perform(get("/vaults/99"))
                .andExpect(status().isInternalServerError());
    }

    // POST /vaults
    @Test
    void createVault_returns200_withCreatedVault() throws Exception
    {
        when(vaultService.createVault(any(VaultRequest.class))).thenReturn(response);

        mockMvc.perform(post("/vaults")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Test Vault"));
    }

    // PUT /vaults/{id}
    @Test
    void updateVault_returns200_whenFound() throws Exception
    {
        when(vaultService.updateVault(eq(1), any(VaultRequest.class))).thenReturn(response);

        mockMvc.perform(put("/vaults/1")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Test Vault"));
    }

    @Test
    void updateVault_returns500_whenNotFound() throws Exception
    {
        when(vaultService.updateVault(eq(99), any(VaultRequest.class))).thenThrow(new RuntimeException("Vault not found."));

        mockMvc.perform(put("/vaults/99")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isInternalServerError());
    }

    // DELETE /vaults/{id}
    @Test
    void deleteVault_returns200() throws Exception
    {
        doNothing().when(vaultService).deleteVault(1);

        mockMvc.perform(delete("/vaults/1").with(csrf()))
                .andExpect(status().isOk());
    }
}