package com.mealchemy.vault.controller;

/* Importing libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import com.mealchemy.config.JwtUtil;

import java.time.OffsetDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.junit.jupiter.api.Assertions.assertTrue;
import jakarta.servlet.ServletException;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import org.springframework.security.test.context.support.WithMockUser;

/* Importing classes */
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.vault.dto.VaultFolderRequest;
import com.mealchemy.vault.dto.VaultFolderResponse;
import com.mealchemy.vault.service.VaultFolderService;

@WithMockUser
@WebMvcTest(VaultFolderController.class)
public class VaultFolderControllerTest
{
    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private VaultFolderService vaultFolderService;

    @MockBean
    private JwtUtil jwtUtil;

    @Autowired
    private ObjectMapper objectMapper;

    private VaultFolderResponse response;
    private VaultFolderRequest request;

    @BeforeEach
    void setUp()
    {
        response = new VaultFolderResponse();
        response.setFolderId(1);
        response.setVaultId(1);
        response.setFolderName("General");
        response.setCreatedAt(OffsetDateTime.now());

        request = new VaultFolderRequest();
        request.setVaultId(1);
        request.setFolderName("General");
    }

    // GET /folders/vault/{vaultId}
    @Test
    void getVaultFolderByVaultId_returns200_withList() throws Exception
    {
        when(vaultFolderService.getVaultFolderByVaultId(1)).thenReturn(List.of(response));

        mockMvc.perform(get("/folders/vault/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].folderName").value("General"));
    }

    @Test
    void getVaultFolderByVaultId_returns200_withEmptyList() throws Exception
    {
        when(vaultFolderService.getVaultFolderByVaultId(99)).thenReturn(List.of());

        mockMvc.perform(get("/folders/vault/99"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isEmpty());
    }

    // GET /folders/folder/name/{name}
    @Test
    void getVaultFolderByName_returns200_whenFound() throws Exception
    {
        when(vaultFolderService.getVaultFolderByName("General")).thenReturn(response);

        mockMvc.perform(get("/folders/folder/name/General"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.folderName").value("General"));
    }

    @Test
    void getVaultFolderByName_returns500_whenNotFound() throws Exception
    {
        when(vaultFolderService.getVaultFolderByName("Nonexistent")).thenThrow(new RuntimeException("Folder not found."));

        assertThrows(ServletException.class, () -> mockMvc.perform(get("/folders/folder/name/Nonexistent"))
                .andExpect(result -> assertTrue(result.getResolvedException() instanceof RuntimeException)));
    }

    // GET /folders/folder/{id}
    @Test
    void getVaultFolderById_returns200_whenFound() throws Exception
    {
        when(vaultFolderService.getVaultFolderById(1)).thenReturn(response);

        mockMvc.perform(get("/folders/folder/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.folderName").value("General"));
    }

    @Test
    void getVaultFolderById_returns500_whenNotFound() throws Exception
    {
        when(vaultFolderService.getVaultFolderById(99)).thenThrow(new RuntimeException("Folder not found."));

        assertThrows(ServletException.class, () -> mockMvc.perform(get("/folders/folder/99"))
                .andExpect(result -> assertTrue(result.getResolvedException() instanceof RuntimeException)));
    }

    // POST /folders
    @Test
    void createVaultFolder_returns200_withCreatedFolder() throws Exception
    {
        when(vaultFolderService.createVaultFolder(any(VaultFolderRequest.class))).thenReturn(response);

        mockMvc.perform(post("/folders")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.folderName").value("General"));
    }

    // PUT /folders/{id}
    @Test
    void updateVaultFolder_returns200_whenFound() throws Exception
    {
        when(vaultFolderService.updateVaultFolder(eq(1), any(VaultFolderRequest.class))).thenReturn(response);

        mockMvc.perform(put("/folders/1")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.folderName").value("General"));
    }
    @Test
    void updateVaultFolder_returns500_whenNotFound() throws Exception
    {
        when(vaultFolderService.updateVaultFolder(eq(99), any(VaultFolderRequest.class))).thenThrow(new RuntimeException("Folder not found."));

        assertThrows(ServletException.class, () -> mockMvc.perform(put("/folders/99")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(result -> assertTrue(result.getResolvedException() instanceof RuntimeException)));
    }

    // DELETE /folders/{id}
    @Test
    void deleteVaultFolder_returns200() throws Exception
    {
        doNothing().when(vaultFolderService).deleteVaultFolder(1);

        mockMvc.perform(delete("/folders/1").with(csrf()))
                .andExpect(status().isOk());
    }
}