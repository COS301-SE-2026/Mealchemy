package com.mealchemy.vault.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.vault.dto.VaultFolderRecipeRequest;
import com.mealchemy.vault.model.VaultFolder;
import com.mealchemy.vault.model.VaultFolderRecipe;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.repository.VaultFolderRecipeRepository;
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
public class VaultFolderRecipeControllerIntegrationTest
{
    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private VaultFolderRecipeRepository vaultFolderRecipeRepository;

    @Autowired
    private VaultFolderRepository vaultFolderRepository;

    @Autowired
    private VaultRepository vaultRepository;

    @Autowired
    private ObjectMapper objectMapper;

    private VaultFolder savedFolder;
    private VaultFolderRecipe savedFolderRecipe;

    private static final int RECIPE_ID = 5;

    @BeforeEach
    void setUp()
    {
        vaultFolderRecipeRepository.deleteAll();
        vaultFolderRepository.deleteAll();
        vaultRepository.deleteAll();

        Vault vault = new Vault();
        vault.setOwnerId(1);
        vault.setVaultType(VaultType.PRIVATE);
        vault.setName("Test Vault");
        Vault savedVault = vaultRepository.save(vault);

        VaultFolder folder = new VaultFolder();
        folder.setVaultId(savedVault.getVaultId());
        folder.setFolderName("Favourites");
        savedFolder = vaultFolderRepository.save(folder);

        VaultFolderRecipe folderRecipe = new VaultFolderRecipe();
        folderRecipe.setFolderId(savedFolder.getFolderId());
        folderRecipe.setRecipeId(RECIPE_ID);
        savedFolderRecipe = vaultFolderRecipeRepository.save(folderRecipe);
    }

    // GET /recipefolders/recipes/{folderId}
    @Test
    void getRecipesByFolderId_returnsRecipeList() throws Exception
    {
        mockMvc.perform(get("/recipefolders/recipes/{folderId}", savedFolder.getFolderId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].folderId", is(savedFolder.getFolderId())))
                .andExpect(jsonPath("$[0].recipeId", is(RECIPE_ID)));
    }

    @Test
    void getRecipesByFolderId_returnsEmptyList_whenNoRecipesInFolder() throws Exception
    {
        mockMvc.perform(get("/recipefolders/recipes/999999"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));
    }

    // GET /recipefolders/folders/{recipeId}
    @Test
    void getFoldersByRecipeId_returnsFolderList() throws Exception
    {
        mockMvc.perform(get("/recipefolders/folders/{recipeId}", RECIPE_ID))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].recipeId", is(RECIPE_ID)))
                .andExpect(jsonPath("$[0].folderId", is(savedFolder.getFolderId())));
    }

    @Test
    void getFoldersByRecipeId_returnsEmptyList_whenRecipeNotInAnyFolder() throws Exception
    {
        mockMvc.perform(get("/recipefolders/folders/999999"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));
    }

    // GET /recipefolders/{id}
    @Test
    void getFolderRecipeById_returnsRecord_whenExists() throws Exception
    {
        mockMvc.perform(get("/recipefolders/{id}", savedFolderRecipe.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(savedFolderRecipe.getId())))
                .andExpect(jsonPath("$.folderId", is(savedFolder.getFolderId())))
                .andExpect(jsonPath("$.recipeId", is(RECIPE_ID)));
    }

    @Test
    void getFolderRecipeById_throws_whenNotFound() throws Exception
    {
        mockMvc.perform(get("/recipefolders/999999"))
                .andExpect(status().is5xxServerError());
    }

    // POST /recipefolders
    @Test
    void createFolderRecipe_persistsAndReturnsRecord() throws Exception
    {
        VaultFolderRecipeRequest request = new VaultFolderRecipeRequest();
        request.setFolderId(savedFolder.getFolderId());
        request.setRecipeId(1);

        mockMvc.perform(post("/recipefolders")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", notNullValue()))
                .andExpect(jsonPath("$.folderId", is(savedFolder.getFolderId())))
                .andExpect(jsonPath("$.recipeId", is(1)))
                .andExpect(jsonPath("$.addedAt", notNullValue()));
    }

    // PUT /recipefolders/{id}
    @Test
    void updateFolderRecipe_updatesAndReturnsRecord() throws Exception
    {
        VaultFolderRecipeRequest request = new VaultFolderRecipeRequest();
        request.setFolderId(savedFolder.getFolderId());
        request.setRecipeId(2);

        mockMvc.perform(put("/recipefolders/{id}", savedFolderRecipe.getId())
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(savedFolderRecipe.getId())))
                .andExpect(jsonPath("$.recipeId", is(2)));
    }

    @Test
    void updateFolderRecipe_throws_whenNotFound() throws Exception
    {
        VaultFolderRecipeRequest request = new VaultFolderRecipeRequest();
        request.setFolderId(savedFolder.getFolderId());
        request.setRecipeId(77);

        mockMvc.perform(put("/recipefolders/999999")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().is5xxServerError());
    }

    // DELETE /recipefolders/{id}
    @Test
    void deleteFolderRecipe_removesRecord() throws Exception
    {
        mockMvc.perform(delete("/recipefolders/{id}", savedFolderRecipe.getId())
                        .with(csrf()))
                .andExpect(status().isOk());

        mockMvc.perform(get("/recipefolders/{id}", savedFolderRecipe.getId()))
                .andExpect(status().is5xxServerError());
    }
}