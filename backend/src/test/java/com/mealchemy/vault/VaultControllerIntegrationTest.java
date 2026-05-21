package com.mealchemy.vault.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.vault.dto.VaultRequest;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.shared.enums.VaultType;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import org.springframework.security.test.context.support.WithMockUser;

import static org.hamcrest.Matchers.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@WithMockUser
public class VaultControllerIntegrationTest
{
    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private VaultRepository vaultRepository;

    @Autowired
    private ObjectMapper objectMapper;

    private Vault savedVault;

    @BeforeEach
    void setUp()
    {
        vaultRepository.deleteAll();

        Vault vault = new Vault();
        vault.setOwnerId(1);
        vault.setVaultType(VaultType.PRIVATE);
        vault.setName("Test Vault");
        savedVault = vaultRepository.save(vault);
    }

    // GET /vaults/owner/{ownerId}
    @Test
    void getVaultsByOwnerId_returnsVaultList() throws Exception
    {
        mockMvc.perform(get("/vaults/owner/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(greaterThanOrEqualTo(1))))
                .andExpect(jsonPath("$[0].name", is("Test Vault")))
                .andExpect(jsonPath("$[0].vaultType", is("PRIVATE")));
    }

    @Test
    void getVaultsByOwnerId_returnsEmptyList_whenNoVaultsExist() throws Exception
    {
        mockMvc.perform(get("/vaults/owner/999"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));
    }

    // GET /vaults/{id}
    @Test
    void getVault_returnsVault_whenExists() throws Exception
    {
        mockMvc.perform(get("/vaults/{id}", savedVault.getVaultId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.vaultId", is(savedVault.getVaultId())))
                .andExpect(jsonPath("$.name", is("Test Vault")))
                .andExpect(jsonPath("$.ownerId", is(1)));
    }

    @Test
    void getVault_throws_whenNotFound() throws Exception
    {
        mockMvc.perform(get("/vaults/999999"))
                .andExpect(status().is5xxServerError());
    }

    // POST /vaults
    @Test
    void createVault_persistsAndReturnsVault() throws Exception
    {
        VaultRequest request = new VaultRequest();
        request.setOwnerId(2);
        request.setVaultType(VaultType.PRIVATE);
        request.setName("New Vault");

        mockMvc.perform(post("/vaults")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.vaultId", notNullValue()))
                .andExpect(jsonPath("$.name", is("New Vault")))
                .andExpect(jsonPath("$.ownerId", is(2)))
                .andExpect(jsonPath("$.vaultType", is("PRIVATE")));
    }

    // PUT /vaults/{id}
    @Test
    void updateVault_updatesAndReturnsVault() throws Exception
    {
        VaultRequest request = new VaultRequest();
        request.setOwnerId(1);
        request.setVaultType(VaultType.PRIVATE);
        request.setName("Updated Vault Name");

        mockMvc.perform(put("/vaults/{id}", savedVault.getVaultId())
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.vaultId", is(savedVault.getVaultId())))
                .andExpect(jsonPath("$.name", is("Updated Vault Name")));
    }

    @Test
    void updateVault_throws_whenNotFound() throws Exception
    {
        VaultRequest request = new VaultRequest();
        request.setOwnerId(1);
        request.setVaultType(VaultType.PRIVATE);
        request.setName("Ghost Vault");

        mockMvc.perform(put("/vaults/999999")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().is5xxServerError());
    }

    // DELETE /vaults/{id}
    @Test
    void deleteVault_removesVault() throws Exception
    {
        mockMvc.perform(delete("/vaults/{id}", savedVault.getVaultId())
                        .with(csrf()))
                .andExpect(status().isOk());

        mockMvc.perform(get("/vaults/{id}", savedVault.getVaultId()))
                .andExpect(status().is5xxServerError());
    }
}