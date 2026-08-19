package com.mealchemy.vault.integration;

import com.mealchemy.auth.model.User;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.vault.dto.VaultFolderRecipeMoveRequest;
import com.mealchemy.vault.dto.VaultFolderRecipeRequest;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.model.VaultFolder;
import com.mealchemy.vault.model.VaultFolderRecipe;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.repository.VaultFolderRecipeRepository;
import com.mealchemy.vault.repository.VaultFolderRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.shared.enums.VaultType;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.greaterThan;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import org.springframework.http.MediaType;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class VaultFolderRecipeControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private VaultFolderRecipeRepository vaultFolderRecipeRepository;

    @Autowired
    private VaultFolderRepository vaultFolderRepository;

    @Autowired
    private VaultMemberRepository vaultMemberRepository;

    @Autowired
    private VaultRepository vaultRepository;

    @Autowired
    private RecipeRepository recipeRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ObjectMapper objectMapper;

    private User owner;
    private User memberUser;
    private User otherUser;
    private User recipeOwner;

    private Vault ownerVault;
    private Vault otherVault;
    private VaultFolder folderInOwnerVault;
    private VaultFolder secondFolderInOwnerVault;
    private VaultFolder folderInOtherVault;

    private Recipe recipe;
    private VaultFolderRecipe vaultFolderRecipe;

    @BeforeEach
    void setUp() {
        vaultFolderRecipeRepository.deleteAll();
        vaultFolderRepository.deleteAll();
        vaultMemberRepository.deleteAll();
        vaultRepository.deleteAll();
        recipeRepository.deleteAll();
        userRepository.deleteAll();

        owner = saveUser("owner@mealchemy.com");
        memberUser = saveUser("member@mealchemy.com");
        otherUser = saveUser("other@mealchemy.com");
        recipeOwner = saveUser("recipeowner@mealchemy.com");

        ownerVault = new Vault();
        ownerVault.setOwnerId(owner.getUserId());
        ownerVault.setVaultType(VaultType.SHARED);
        ownerVault.setName("Owner's Vault");
        ownerVault = vaultRepository.save(ownerVault);

        VaultMember membership = new VaultMember();
        membership.setVault(ownerVault);
        membership.setUser(memberUser);
        vaultMemberRepository.save(membership);

        otherVault = new Vault();
        otherVault.setOwnerId(otherUser.getUserId());
        otherVault.setVaultType(VaultType.SHARED);
        otherVault.setName("Other Vault");
        otherVault = vaultRepository.save(otherVault);

        folderInOwnerVault = saveFolder(ownerVault, "Weeknight Dinners");
        secondFolderInOwnerVault = saveFolder(ownerVault, "Desserts");
        folderInOtherVault = saveFolder(otherVault, "Other Vault Folder");

        recipe = saveRecipe(recipeOwner, "Test Recipe");

        vaultFolderRecipe = new VaultFolderRecipe();
        vaultFolderRecipe.setFolder(folderInOwnerVault);
        vaultFolderRecipe.setRecipe(recipe);
        vaultFolderRecipe.setAddedBy(memberUser);
        vaultFolderRecipe = vaultFolderRecipeRepository.save(vaultFolderRecipe);
    }

    private User saveUser(String email) {
        User user = new User();
        user.setEmail(email);
        user.setPasswordHash("hashed-password");
        user.setRoles(List.of("USER"));
        return userRepository.save(user);
    }

    private VaultFolder saveFolder(Vault vault, String name) {
        VaultFolder folder = new VaultFolder();
        folder.setVault(vault);
        folder.setFolderName(name);
        return vaultFolderRepository.save(folder);
    }

    private Recipe saveRecipe(User owner, String title) {
        Recipe recipe = new Recipe();
        recipe.setOwnerId(owner.getUserId());
        recipe.setTitle(title);
        recipe.setDescription("A test recipe description");
        recipe.setCuisineType("Test Cuisine");
        recipe.setPrepTimeMins(10);
        recipe.setCookingTimeMins(20);
        recipe.setServingSize(4);
        return recipeRepository.save(recipe);
    }

    private UsernamePasswordAuthenticationToken authAs(User user) {
        return new UsernamePasswordAuthenticationToken(
                String.valueOf(user.getUserId()),
                null,
                List.of()
        );
    }

    /* getRecipesByFolderId */

    @Test
    void getRecipesByFolderId_returnsList_whenAuthenticatedUserIsOwner() throws Exception {
        mockMvc.perform(get("/recipefolders/recipes/{folderId}", folderInOwnerVault.getFolderId())
                        .with(authentication(authAs(owner))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].folderId", is(folderInOwnerVault.getFolderId())))
                .andExpect(jsonPath("$[0].recipeId", is(recipe.getRecipeId())));
    }

    @Test
    void getRecipesByFolderId_returnsList_whenAuthenticatedUserIsMember() throws Exception {
        mockMvc.perform(get("/recipefolders/recipes/{folderId}", folderInOwnerVault.getFolderId())
                        .with(authentication(authAs(memberUser))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)));
    }

    @Test
    void getRecipesByFolderId_returns404_whenFolderNotFound() throws Exception {
        mockMvc.perform(get("/recipefolders/recipes/{folderId}", 999999)
                        .with(authentication(authAs(owner))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message", is("Folder not found.")));
    }

    @Test
    void getRecipesByFolderId_returns403_whenNotOwnerOrMember() throws Exception {
        mockMvc.perform(get("/recipefolders/recipes/{folderId}", folderInOwnerVault.getFolderId())
                        .with(authentication(authAs(otherUser))))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message", is("Only a vault member/owner can can interact with folders/recipe relationships.")));
    }

    /* getFoldersByRecipeId */

    @Test
    void getFoldersByRecipeId_returnsList_whenAuthenticatedUserIsRecipeOwner() throws Exception {
        mockMvc.perform(get("/recipefolders/folders/{recipeId}", recipe.getRecipeId())
                        .with(authentication(authAs(recipeOwner))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].recipeId", is(recipe.getRecipeId())));
    }

    @Test
    void getFoldersByRecipeId_returns404_whenRecipeNotFound() throws Exception {
        mockMvc.perform(get("/recipefolders/folders/{recipeId}", 999999)
                        .with(authentication(authAs(recipeOwner))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message", is("Recipe not found.")));
    }

    @Test
    void getFoldersByRecipeId_returns403_whenNotRecipeOwner() throws Exception {
        mockMvc.perform(get("/recipefolders/folders/{recipeId}", recipe.getRecipeId())
                        .with(authentication(authAs(owner))))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message", is("Only the recipe owner can see where it has been added.")));
    }

    /* getFolderRecipeById */

    @Test
    void getFolderRecipeById_returnsRecord_whenAuthenticatedUserIsOwner() throws Exception {
        mockMvc.perform(get("/recipefolders/{id}", vaultFolderRecipe.getId())
                        .with(authentication(authAs(owner))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(vaultFolderRecipe.getId())))
                .andExpect(jsonPath("$.recipeId", is(recipe.getRecipeId())));
    }

    @Test
    void getFolderRecipeById_returnsRecord_whenAuthenticatedUserIsMember() throws Exception {
        mockMvc.perform(get("/recipefolders/{id}", vaultFolderRecipe.getId())
                        .with(authentication(authAs(memberUser))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(vaultFolderRecipe.getId())));
    }

    @Test
    void getFolderRecipeById_returns404_whenNotFound() throws Exception {
        mockMvc.perform(get("/recipefolders/{id}", 999999)
                        .with(authentication(authAs(owner))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message", is("No record found.")));
    }

    @Test
    void getFolderRecipeById_returns403_whenNotOwnerOrMember() throws Exception {
        mockMvc.perform(get("/recipefolders/{id}", vaultFolderRecipe.getId())
                        .with(authentication(authAs(otherUser))))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message", is("Only a vault member/owner can can interact with folders/recipe relationships.")));
    }

    /* createVaultFolderRecipe */

    @Test
    void createVaultFolderRecipe_createsRecord_whenAuthenticatedUserIsOwner() throws Exception {
        Recipe secondRecipe = saveRecipe(recipeOwner, "Second Recipe");
        VaultFolderRecipeRequest request = new VaultFolderRecipeRequest(folderInOwnerVault.getFolderId(), secondRecipe.getRecipeId());

        mockMvc.perform(post("/recipefolders/folder/{folderId}", folderInOwnerVault.getFolderId())
                        .with(authentication(authAs(owner)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", notNullValue()))
                .andExpect(jsonPath("$.folderId", is(folderInOwnerVault.getFolderId())))
                .andExpect(jsonPath("$.recipeId", is(secondRecipe.getRecipeId())))
                .andExpect(jsonPath("$.addedByUserId", is(owner.getUserId())))
                .andExpect(jsonPath("$.addedAt", notNullValue()));

        List<VaultFolderRecipe> saved = vaultFolderRecipeRepository.findByFolder_FolderId(folderInOwnerVault.getFolderId());
        org.junit.jupiter.api.Assertions.assertEquals(2, saved.size());
    }

    @Test
    void createVaultFolderRecipe_returns404_whenFolderNotFound() throws Exception {
        VaultFolderRecipeRequest request = new VaultFolderRecipeRequest(999999, recipe.getRecipeId());

        mockMvc.perform(post("/recipefolders/folder/{folderId}", 999999)
                        .with(authentication(authAs(owner)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message", is("Folder not found.")));
    }

    @Test
    void createVaultFolderRecipe_returns403_whenNotOwnerOrMember() throws Exception {
        VaultFolderRecipeRequest request = new VaultFolderRecipeRequest(folderInOwnerVault.getFolderId(), recipe.getRecipeId());

        mockMvc.perform(post("/recipefolders/folder/{folderId}", folderInOwnerVault.getFolderId())
                        .with(authentication(authAs(otherUser)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message", is("Only a vault member/owner can can interact with folders/recipe relationships.")));
    }

    @Test
    void createVaultFolderRecipe_returns404_whenRecipeNotFound() throws Exception {
        VaultFolderRecipeRequest request = new VaultFolderRecipeRequest(folderInOwnerVault.getFolderId(), 999999);

        mockMvc.perform(post("/recipefolders/folder/{folderId}", folderInOwnerVault.getFolderId())
                        .with(authentication(authAs(owner)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message", is("Recipe not found.")));
    }

    /* updateVaultFolderRecipe */

    @Test
    void updateVaultFolderRecipe_movesRecord_whenAuthenticatedUserIsOwner() throws Exception {
        VaultFolderRecipeMoveRequest request = new VaultFolderRecipeMoveRequest(secondFolderInOwnerVault.getFolderId());

        mockMvc.perform(put("/recipefolders/{id}", vaultFolderRecipe.getId())
                        .with(authentication(authAs(owner)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(vaultFolderRecipe.getId())))
                .andExpect(jsonPath("$.folderId", is(secondFolderInOwnerVault.getFolderId())));

        VaultFolderRecipe updated = vaultFolderRecipeRepository.findById(vaultFolderRecipe.getId())
                .orElseThrow(() -> new IllegalStateException("Updated record was not found"));
        org.junit.jupiter.api.Assertions.assertEquals(secondFolderInOwnerVault.getFolderId(), updated.getFolder().getFolderId());
    }

    @Test
    void updateVaultFolderRecipe_returns400_whenFolderIdNull() throws Exception {
        VaultFolderRecipeMoveRequest request = new VaultFolderRecipeMoveRequest(null);

        mockMvc.perform(put("/recipefolders/{id}", vaultFolderRecipe.getId())
                        .with(authentication(authAs(owner)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message", is("folderId: must not be null")));
    }

    @Test
    void updateVaultFolderRecipe_returns404_whenRecordNotFound() throws Exception {
        VaultFolderRecipeMoveRequest request = new VaultFolderRecipeMoveRequest(secondFolderInOwnerVault.getFolderId());

        mockMvc.perform(put("/recipefolders/{id}", 999999)
                        .with(authentication(authAs(owner)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message", is("No record found.")));
    }

    @Test
    void updateVaultFolderRecipe_returns403_whenAuthenticatedUserIsNotOwner() throws Exception {
        VaultFolderRecipeMoveRequest request = new VaultFolderRecipeMoveRequest(secondFolderInOwnerVault.getFolderId());

        mockMvc.perform(put("/recipefolders/{id}", vaultFolderRecipe.getId())
                        .with(authentication(authAs(memberUser)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message", is("Only a vault owner can interact with folders/recipe relationships.")));
    }

    @Test
    void updateVaultFolderRecipe_returns404_whenNewFolderNotFound() throws Exception {
        VaultFolderRecipeMoveRequest request = new VaultFolderRecipeMoveRequest(999999);

        mockMvc.perform(put("/recipefolders/{id}", vaultFolderRecipe.getId())
                        .with(authentication(authAs(owner)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message", is("New folder not found.")));
    }

    @Test
    void updateVaultFolderRecipe_returns403_whenMovingBetweenDifferentVaults() throws Exception {
        VaultFolderRecipeMoveRequest request = new VaultFolderRecipeMoveRequest(folderInOtherVault.getFolderId());

        mockMvc.perform(put("/recipefolders/{id}", vaultFolderRecipe.getId())
                        .with(authentication(authAs(owner)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message", is("Recipes can only moved between folders in the same vault.")));
    }

    /* deleteVaultFolderRecipe */

    @Test
    void deleteVaultFolderRecipe_deletesRecord_whenAuthenticatedUserIsOwner() throws Exception {
        mockMvc.perform(delete("/recipefolders/{id}", vaultFolderRecipe.getId())
                        .with(authentication(authAs(owner)))
                        .with(csrf()))
                .andExpect(status().isOk());

        org.junit.jupiter.api.Assertions.assertFalse(
                vaultFolderRecipeRepository.findById(vaultFolderRecipe.getId()).isPresent()
        );
    }

    @Test
    void deleteVaultFolderRecipe_deletesRecord_whenAuthenticatedUserIsMemberWhoAdded() throws Exception {
        mockMvc.perform(delete("/recipefolders/{id}", vaultFolderRecipe.getId())
                        .with(authentication(authAs(memberUser)))
                        .with(csrf()))
                .andExpect(status().isOk());

        org.junit.jupiter.api.Assertions.assertFalse(
                vaultFolderRecipeRepository.findById(vaultFolderRecipe.getId()).isPresent()
        );
    }

    @Test
    void deleteVaultFolderRecipe_returns404_whenRecordNotFound() throws Exception {
        mockMvc.perform(delete("/recipefolders/{id}", 999999)
                        .with(authentication(authAs(owner)))
                        .with(csrf()))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message", is("No record found.")));
    }

    @Test
    void deleteVaultFolderRecipe_returns403_whenNotOwnerOrAddingMember() throws Exception {
        mockMvc.perform(delete("/recipefolders/{id}", vaultFolderRecipe.getId())
                        .with(authentication(authAs(otherUser)))
                        .with(csrf()))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message", is("Only a vault member who added the recipe/vault owner can delete the folders.")));

        org.junit.jupiter.api.Assertions.assertTrue(
                vaultFolderRecipeRepository.findById(vaultFolderRecipe.getId()).isPresent()
        );
    }
}
