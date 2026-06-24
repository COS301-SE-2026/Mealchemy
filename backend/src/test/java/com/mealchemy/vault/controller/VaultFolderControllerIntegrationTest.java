package com.mealchemy.vault.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.vault.dto.VaultFolderRequest;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.model.VaultFolder;
import com.mealchemy.vault.repository.VaultFolderRepository;
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
public class VaultFolderControllerIntegrationTest
{
    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private VaultFolderRepository vaultFolderRepository;

    @Autowired
    private VaultRepository vaultRepository;

    @Autowired
    private ObjectMapper objectMapper;

    private Vault savedVault;
    private VaultFolder savedFolder;

    @BeforeEach
    void setUp()
    {
        vaultFolderRepository.deleteAll();
        vaultRepository.deleteAll();

        Vault vault = new Vault();
        vault.setOwnerId(1);
        vault.setVaultType(VaultType.PRIVATE);
        vault.setName("Test Vault");
        savedVault = vaultRepository.save(vault);

        VaultFolder folder = new VaultFolder();
        folder.setVaultId(savedVault.getVaultId());
        folder.setFolderName("Breakfast");
        savedFolder = vaultFolderRepository.save(folder);
    }

    // GET /folders/vault/{vaultId}
    @Test
    void getFoldersByVaultId_returnsFolderList() throws Exception
    {
        mockMvc.perform(get("/folders/vault/{vaultId}", savedVault.getVaultId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].folderName", is("Breakfast")))
                .andExpect(jsonPath("$[0].vaultId", is(savedVault.getVaultId())));
    }

    @Test
    void getFoldersByVaultId_returnsEmptyList_whenNoFoldersExist() throws Exception
    {
        mockMvc.perform(get("/folders/vault/999999"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));
    }

    // GET /folders/folder/name/{name}
    @Test
    void getFolderByName_returnsFolder_whenExists() throws Exception
    {
        mockMvc.perform(get("/folders/folder/name/Breakfast"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.folderName", is("Breakfast")))
                .andExpect(jsonPath("$.folderId", is(savedFolder.getFolderId())));
    }

    @Test
    void getFolderByName_throws_whenNotFound() throws Exception
    {
        mockMvc.perform(get("/folders/folder/name/NonExistentFolder"))
                .andExpect(status().is5xxServerError());
    }

    // GET /folders/folder/{id}
    @Test
    void getFolderById_returnsFolder_whenExists() throws Exception
    {
        mockMvc.perform(get("/folders/folder/{id}", savedFolder.getFolderId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.folderId", is(savedFolder.getFolderId())))
                .andExpect(jsonPath("$.folderName", is("Breakfast")));
    }

    @Test
    void getFolderById_throws_whenNotFound() throws Exception
    {
        mockMvc.perform(get("/folders/folder/999999"))
                .andExpect(status().is5xxServerError());
    }

    // POST /folders
    @Test
    void createFolder_persistsAndReturnsFolder() throws Exception
    {
        VaultFolderRequest request = new VaultFolderRequest();
        request.setVaultId(savedVault.getVaultId());
        request.setFolderName("Dinner");

        mockMvc.perform(post("/folders")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.folderId", notNullValue()))
                .andExpect(jsonPath("$.folderName", is("Dinner")))
                .andExpect(jsonPath("$.vaultId", is(savedVault.getVaultId())));
    }

    // PUT /folders/{id}
    @Test
    void updateFolder_updatesAndReturnsFolder() throws Exception
    {
        VaultFolderRequest request = new VaultFolderRequest();
        request.setVaultId(savedVault.getVaultId());
        request.setFolderName("Brunch");

        mockMvc.perform(put("/folders/{id}", savedFolder.getFolderId())
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.folderId", is(savedFolder.getFolderId())))
                .andExpect(jsonPath("$.folderName", is("Brunch")));
    }

    @Test
    void updateFolder_throws_whenNotFound() throws Exception
    {
        VaultFolderRequest request = new VaultFolderRequest();
        request.setVaultId(savedVault.getVaultId());
        request.setFolderName("Ghost Folder");

        mockMvc.perform(put("/folders/999999")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().is5xxServerError());
    }

    // DELETE /folders/{id}
    @Test
    void deleteFolder_removesFolder() throws Exception
    {
        mockMvc.perform(delete("/folders/{id}", savedFolder.getFolderId())
                        .with(csrf()))
                .andExpect(status().isOk());

        mockMvc.perform(get("/folders/folder/{id}", savedFolder.getFolderId()))
                .andExpect(status().is5xxServerError());
    }
}