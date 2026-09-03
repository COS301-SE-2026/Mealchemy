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
import com.mealchemy.vault.dto.VaultFolderRecipeRequest;
import com.mealchemy.vault.dto.VaultFolderRecipeMoveRequest;
import com.mealchemy.vault.dto.VaultFolderRecipeResponse;
import com.mealchemy.vault.service.VaultFolderRecipeService;
import com.mealchemy.config.WithMockJwtUser;

@ExtendWith(SpringExtension.class)
@WebMvcTest(VaultFolderRecipeController.class)
@WithMockJwtUser(userId = "1")
public class VaultFolderRecipeControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @MockitoBean 
    private JwtUtil jwtUtil;

    @MockitoBean
    private VaultFolderRecipeService vaultFolderRecipeService;

    @Autowired
    private ObjectMapper objectMapper;

    private VaultFolderRecipeResponse response;
    private VaultFolderRecipeRequest request;
    private VaultFolderRecipeMoveRequest moveRequest;

    @BeforeEach
    void setUp()
    {
        response = new VaultFolderRecipeResponse(1, 1, 1, OffsetDateTime.now(), 1);

        request = new VaultFolderRecipeRequest(1, 1);

        moveRequest = new VaultFolderRecipeMoveRequest(2);
    }

    @Test
    void getRecipesByFolderId_returns200_withList() throws Exception
    {
        when(vaultFolderRecipeService.getRecipesByFolderId(1, 1)).thenReturn(List.of(response));

        mockMvc.perform(get("/recipefolders/recipes/1")).andExpect(status().isOk()).andExpect(jsonPath("$[0].recipeId").value(1));
    }

    @Test
    void getRecipesByFolderId_returns404_whenFolderNotFound() throws Exception
    {
        when(vaultFolderRecipeService.getRecipesByFolderId(99, 1)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found."));

        mockMvc.perform(get("/recipefolders/recipes/99")).andExpect(status().isNotFound()).andExpect(jsonPath("$.message").value("Folder not found."));
    }

    @Test
    void getFoldersByRecipeId_returns200_withList() throws Exception
    {
        when(vaultFolderRecipeService.getFoldersByRecipeId(1, 1)).thenReturn(List.of(response));

        mockMvc.perform(get("/recipefolders/folders/1")).andExpect(status().isOk()).andExpect(jsonPath("$[0].folderId").value(1));
    }

    @Test
    void getFoldersByRecipeId_returns403_whenNotRecipeOwner() throws Exception
    {
        when(vaultFolderRecipeService.getFoldersByRecipeId(1, 1))
            .thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the recipe owner can see where it has been added."));

        mockMvc.perform(get("/recipefolders/folders/1")).andExpect(status().isForbidden()).andExpect(jsonPath("$.message").value("Only the recipe owner can see where it has been added."));
    }

    @Test
    void getFolderRecipeById_returns200_whenFound() throws Exception
    {
        when(vaultFolderRecipeService.getFolderRecipeById(1, 1)).thenReturn(response);

        mockMvc.perform(get("/recipefolders/1")).andExpect(status().isOk()).andExpect(jsonPath("$.id").value(1));
    }

    @Test
    void getFolderRecipeById_returns404_whenNotFound() throws Exception
    {
        when(vaultFolderRecipeService.getFolderRecipeById(99, 1)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "No record found."));

        mockMvc.perform(get("/recipefolders/99")).andExpect(status().isNotFound()).andExpect(jsonPath("$.message").value("No record found."));
    }

    @Test
    void createVaultFolderRecipe_returns200_withCreatedRecord() throws Exception
    {
        when(vaultFolderRecipeService.createVaultFolderRecipe(any(VaultFolderRecipeRequest.class), eq(1), eq(1))).thenReturn(response);

        mockMvc.perform(post("/recipefolders/folder/1")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.recipeId").value(1));
    }

    @Test
    void createVaultFolderRecipe_returns403_whenNotOwnerOrMember() throws Exception
    {
        when(vaultFolderRecipeService.createVaultFolderRecipe(any(VaultFolderRecipeRequest.class), eq(1), eq(1)))
            .thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "Only a vault member/owner can can interact with folders/recipe relationships."));

        mockMvc.perform(post("/recipefolders/folder/1")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value("Only a vault member/owner can can interact with folders/recipe relationships."));
    }

    @Test
    void updateVaultFolderRecipe_returns200_withUpdatedRecord() throws Exception
    {
        when(vaultFolderRecipeService.updateVaultFolderRecipe(eq(1), any(VaultFolderRecipeMoveRequest.class), eq(1))).thenReturn(response);

        mockMvc.perform(put("/recipefolders/1")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(moveRequest)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.recipeId").value(1));
    }

    @Test
    void updateVaultFolderRecipe_returns403_whenFoldersFromDifferentVaults() throws Exception
    {
        when(vaultFolderRecipeService.updateVaultFolderRecipe(eq(1), any(VaultFolderRecipeMoveRequest.class), eq(1)))
            .thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "Recipes can only moved between folders in the same vault."));

        mockMvc.perform(put("/recipefolders/1")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(moveRequest)))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value("Recipes can only moved between folders in the same vault."));
    }

    @Test
    void deleteVaultFolderRecipe_returns204() throws Exception
    {
        doNothing().when(vaultFolderRecipeService).deleteVaultFolderRecipe(1, 1);

        mockMvc.perform(delete("/recipefolders/1").with(csrf()))
            .andExpect(status().isNoContent());
    }

    @Test
    void deleteVaultFolderRecipe_returns403_whenNotOwnerOrMemberWhoAdded() throws Exception
    {
        doThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "Only a vault member who added the recipe/vault owner can delete the folders."))
            .when(vaultFolderRecipeService).deleteVaultFolderRecipe(1, 1);

        mockMvc.perform(delete("/recipefolders/1").with(csrf()))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value("Only a vault member who added the recipe/vault owner can delete the folders."));
    }
}