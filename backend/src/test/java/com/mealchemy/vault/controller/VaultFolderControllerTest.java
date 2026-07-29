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
import com.mealchemy.vault.dto.VaultFolderRequest;
import com.mealchemy.vault.dto.VaultFolderResponse;
import com.mealchemy.vault.service.VaultFolderService;
import com.mealchemy.config.WithMockJwtUser;

@ExtendWith(SpringExtension.class)
@WebMvcTest(VaultFolderController.class)
@WithMockJwtUser(userId = "1")
public class VaultFolderControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @MockitoBean 
    private JwtUtil jwtUtil;

    @MockitoBean
    private VaultFolderService vaultFolderService;

    @Autowired
    private ObjectMapper objectMapper;

    private VaultFolderResponse response;
    private VaultFolderRequest request;

    @BeforeEach
    void setUp()
    {
        response = new VaultFolderResponse(1, 1, "General", OffsetDateTime.now());

        request = new VaultFolderRequest(1, "General");
    }

    @Test
    void getPrivateVaultFolders_returns200_withList() throws Exception
    {
        when(vaultFolderService.getPrivateVaultFolders(1)).thenReturn(List.of(response));

        mockMvc.perform(get("/folders/vault/private")).andExpect(status().isOk()).andExpect(jsonPath("$[0].folderName").value("General"));
    }

    @Test
    void getPrivateVaultFolders_returns404_whenPrivateVaultNotFound() throws Exception
    {
        when(vaultFolderService.getPrivateVaultFolders(1)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Private vault not found."));

        mockMvc.perform(get("/folders/vault/private")).andExpect(status().isNotFound()).andExpect(jsonPath("$.message").value("Private vault not found."));
    }

    @Test
    void getVaultFolderByVaultId_returns200_withList() throws Exception
    {
        when(vaultFolderService.getVaultFolderByVaultId(1, 1)).thenReturn(List.of(response));

        mockMvc.perform(get("/folders/vault/1")).andExpect(status().isOk()).andExpect(jsonPath("$[0].folderName").value("General"));
    }

    @Test
    void getVaultFolderByVaultId_returns404_whenVaultNotFound() throws Exception
    {
        when(vaultFolderService.getVaultFolderByVaultId(99, 1)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        mockMvc.perform(get("/folders/vault/99")).andExpect(status().isNotFound()).andExpect(jsonPath("$.message").value("Vault not found."));
    }

    @Test
    void getVaultFolderByName_returns200_whenFound() throws Exception
    {
        when(vaultFolderService.getVaultFolderByName("General", 1, 1)).thenReturn(response);

        mockMvc.perform(get("/folders/1/folder/name/General")).andExpect(status().isOk()).andExpect(jsonPath("$.folderName").value("General"));
    }

    @Test
    void getVaultFolderByName_returns404_whenNotFound() throws Exception
    {
        when(vaultFolderService.getVaultFolderByName("Missing", 1, 1)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found."));

        mockMvc.perform(get("/folders/1/folder/name/Missing")).andExpect(status().isNotFound()).andExpect(jsonPath("$.message").value("Folder not found."));
    }

    @Test
    void getVaultFolderById_returns200_whenFound() throws Exception
    {
        when(vaultFolderService.getVaultFolderById(1, 1, 1)).thenReturn(response);

        mockMvc.perform(get("/folders/1/folder/1")).andExpect(status().isOk()).andExpect(jsonPath("$.folderName").value("General"));
    }

    @Test
    void getVaultFolderById_returns404_whenNotFound() throws Exception
    {
        when(vaultFolderService.getVaultFolderById(99, 1, 1)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found."));

        mockMvc.perform(get("/folders/1/folder/99")).andExpect(status().isNotFound()).andExpect(jsonPath("$.message").value("Folder not found."));
    }

    @Test
    void createVaultFolder_returns200_withCreatedFolder() throws Exception
    {
        when(vaultFolderService.createVaultFolder(any(VaultFolderRequest.class), eq(1))).thenReturn(response);

        mockMvc.perform(post("/folders")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.folderName").value("General"));
    }

    @Test
    void createVaultFolder_returns400_whenFolderNameBlank() throws Exception
    {
        VaultFolderRequest invalidRequest = new VaultFolderRequest(1, "");

        mockMvc.perform(post("/folders")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(invalidRequest)))
            .andExpect(status().isBadRequest());
    }

    @Test
    void createVaultFolder_returns403_whenNotOwner() throws Exception
    {
        when(vaultFolderService.createVaultFolder(any(VaultFolderRequest.class), eq(1)))
            .thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "Only a vault owner can modify folders."));

        mockMvc.perform(post("/folders")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value("Only a vault owner can modify folders."));
    }

    @Test
    void updateVaultFolder_returns200_withUpdatedFolder() throws Exception
    {
        when(vaultFolderService.updateVaultFolder(eq(1), any(VaultFolderRequest.class), eq(1))).thenReturn(response);

        mockMvc.perform(put("/folders/1")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.folderName").value("General"));
    }

    @Test
    void updateVaultFolder_returns404_whenFolderNotFound() throws Exception
    {
        when(vaultFolderService.updateVaultFolder(eq(99), any(VaultFolderRequest.class), eq(1)))
            .thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found."));

        mockMvc.perform(put("/folders/99")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("Folder not found."));
    }

    @Test
    void deleteVaultFolder_returns200() throws Exception
    {
        doNothing().when(vaultFolderService).deleteVaultFolder(1, 1, 1);

        mockMvc.perform(delete("/folders/vault/1/folder/1").with(csrf()))
            .andExpect(status().isOk());
    }

    @Test
    void deleteVaultFolder_returns403_whenNotOwner() throws Exception
    {
        doThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "Only a vault owner can modify folders."))
            .when(vaultFolderService).deleteVaultFolder(1, 1, 1);

        mockMvc.perform(delete("/folders/vault/1/folder/1").with(csrf()))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value("Only a vault owner can modify folders."));
    }
}