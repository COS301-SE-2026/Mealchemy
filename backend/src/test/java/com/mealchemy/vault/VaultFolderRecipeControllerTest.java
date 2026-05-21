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
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import org.springframework.security.test.context.support.WithMockUser;

/* Importing classes */
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.vault.dto.VaultFolderRecipeRequest;
import com.mealchemy.vault.dto.VaultFolderRecipeResponse;
import com.mealchemy.vault.service.VaultFolderRecipeService;

@WithMockUser
@WebMvcTest(VaultFolderRecipeController.class)
public class VaultFolderRecipeControllerTest
{
    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private VaultFolderRecipeService vaultFolderRecipeService;

    @MockBean   
    private JwtUtil jwtUtil;

    @Autowired
    private ObjectMapper objectMapper;

    private VaultFolderRecipeResponse response;
    private VaultFolderRecipeRequest request;

    @BeforeEach
    void setUp()
    {
        response = new VaultFolderRecipeResponse();
        response.setId(1);
        response.setFolderId(1);
        response.setRecipeId(1);
        response.setAddedAt(OffsetDateTime.now());

        request = new VaultFolderRecipeRequest();
        request.setFolderId(1);
        request.setRecipeId(1);
    }

    // GET /recipefolders/recipes/{folderId}
    
    @Test
    void getRecipesByFolderId_returns200_withList() throws Exception
    {
        when(vaultFolderRecipeService.getRecipesByFolderId(1)).thenReturn(List.of(response));

        mockMvc.perform(get("/recipefolders/recipes/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].folderId").value(1));
    }

    @Test
    void getRecipesByFolderId_returns200_withEmptyList() throws Exception
    {
        when(vaultFolderRecipeService.getRecipesByFolderId(99)).thenReturn(List.of());

        mockMvc.perform(get("/recipefolders/recipes/99"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isEmpty());
    }

    // GET /recipefolders/folders/{recipeId}
    @Test
    void getFoldersByRecipeId_returns200_withList() throws Exception
    {
        when(vaultFolderRecipeService.getFoldersByRecipeId(1)).thenReturn(List.of(response));

        mockMvc.perform(get("/recipefolders/folders/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].recipeId").value(1));
    }

    @Test
    void getFoldersByRecipeId_returns200_withEmptyList() throws Exception
    {
        when(vaultFolderRecipeService.getFoldersByRecipeId(99)).thenReturn(List.of());

        mockMvc.perform(get("/recipefolders/folders/99"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isEmpty());
    }

    // GET /recipefolders/{id}
    @Test
    void getFolderRecipeById_returns200_whenFound() throws Exception
    {
        when(vaultFolderRecipeService.getFolderRecipeById(1)).thenReturn(response);

        mockMvc.perform(get("/recipefolders/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.folderId").value(1));
    }

    @Test
    void getFolderRecipeById_returns500_whenNotFound() throws Exception
    {
        when(vaultFolderRecipeService.getFolderRecipeById(99)).thenThrow(new RuntimeException("No record found"));

        mockMvc.perform(get("/recipefolders/99"))
                .andExpect(status().isInternalServerError());
    }

    // POST /recipefolders
    @Test
    void createVaultFolderRecipe_returns200_withCreatedRecord() throws Exception
    {
        when(vaultFolderRecipeService.createVaultFolderRecipe(any(VaultFolderRecipeRequest.class))).thenReturn(response);

        mockMvc.perform(post("/recipefolders")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.folderId").value(1));
    }

    // PUT /recipefolders/{id}
    @Test
    void updateVaultFolderRecipe_returns200_whenFound() throws Exception
    {
        when(vaultFolderRecipeService.updateVaultFolderRecipe(eq(1), any(VaultFolderRecipeRequest.class))).thenReturn(response);

        mockMvc.perform(put("/recipefolders/1")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.folderId").value(1));
    }
    @Test
    void updateVaultFolderRecipe_returns500_whenNotFound() throws Exception
    {
        when(vaultFolderRecipeService.updateVaultFolderRecipe(eq(99), any(VaultFolderRecipeRequest.class))).thenThrow(new RuntimeException("No record found"));

        mockMvc.perform(put("/recipefolders/99")
                .with(csrf())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isInternalServerError());
    }

    // DELETE /recipefolders/{id}
    @Test
    void deleteVaultFolderRecipe_returns200() throws Exception
    {
        doNothing().when(vaultFolderRecipeService).deleteVaultFolderRecipe(1);

        mockMvc.perform(delete("/recipefolders/1").with(csrf()))
                .andExpect(status().isOk());
    }
}