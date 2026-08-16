package com.mealchemy.recipe.integration;

import com.mealchemy.auth.model.User;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.recipe.dto.RecipeRequest;
import com.mealchemy.recipe.dto.RecipeFullRequest;
import com.mealchemy.recipe.dto.RecipeIngredientRequest;
import com.mealchemy.recipe.dto.RecipeStepRequest;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.model.VaultFolder;
import com.mealchemy.vault.model.VaultFolderRecipe;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.repository.VaultFolderRepository;
import com.mealchemy.vault.repository.VaultFolderRecipeRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.shared.enums.VaultType;
import com.mealchemy.cuisinetype.repository.FlavourProfileOptionsRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.math.BigDecimal;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.http.MediaType;

import static org.hamcrest.Matchers.hasItems;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class RecipeControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private RecipeRepository recipeRepository;

    @Autowired
    private VaultRepository vaultRepository;

    @Autowired
    private VaultFolderRepository vaultFolderRepository;

    @Autowired
    private VaultFolderRecipeRepository vaultFolderRecipeRepository;

    @Autowired
    private VaultMemberRepository vaultMemberRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private FlavourProfileOptionsRepository flavourProfileOptionsRepository;

    @Autowired
    private IngredientCatalogueRepository ingredientCatalogueRepository;

    @Autowired
    private ObjectMapper objectMapper;


    private String validCuisine;

    private User owner;
    private User otherUser;
    private Vault privateVault;
    private VaultFolder privateFolder;
    private Integer ingId;

    @BeforeEach
    void setUp() {
        
        vaultFolderRecipeRepository.deleteAll();
        vaultMemberRepository.deleteAll();
        recipeRepository.deleteAll();
        vaultFolderRepository.deleteAll();
        vaultRepository.deleteAll();
        userRepository.deleteAll();

        owner = newUser("owner@gmail.com");
        otherUser = newUser("other@gmail.com");

        privateVault = new Vault();
        privateVault.setOwnerId(owner.getUserId());
        privateVault.setVaultType(VaultType.PRIVATE);
        privateVault.setName("My Vault");
        privateVault = vaultRepository.save(privateVault);

        privateFolder = new VaultFolder();
        privateFolder.setVault(privateVault);
        privateFolder.setFolderName("My Recipes");
        privateFolder = vaultFolderRepository.save(privateFolder);

        validCuisine = flavourProfileOptionsRepository.findAll()
                .stream().findFirst()
                .orElseThrow(() -> new IllegalStateException("No rows seeded in flavour_profile_options"))
                .getValue();

        ingId = ingredientCatalogueRepository.findAll()
                .stream().findFirst()
                .orElseThrow(() -> new IllegalStateException("No rows seeded in ingredient_catalogue"))
                .getIngId();
    }

    // Helpers

    private User newUser(String email) {
        User user = new User();
        user.setEmail(email);
        user.setPasswordHash("hashed-password");
        user.setRoles(List.of("USER"));
        return userRepository.save(user);
    }

    // read / update / delete tests have a row to work against.
    private Recipe saveRecipe(User owner, String title) {
        Recipe recipe = new Recipe();
        recipe.setOwnerId(owner.getUserId());
        recipe.setTitle(title);
        recipe.setDescription("A description.");
        recipe.setCuisineType(validCuisine);
        recipe.setPrepTimeMins(10);
        recipe.setCookingTimeMins(20);
        recipe.setServingSize(2);
        recipe.setIsCommunityPublished(false);
        return recipeRepository.save(recipe);
    }

    private Recipe savePublishedRecipe(User owner, String title) {
        Recipe recipe = new Recipe();
        recipe.setOwnerId(owner.getUserId());
        recipe.setTitle(title);
        recipe.setDescription("A description.");
        recipe.setCuisineType(validCuisine);
        recipe.setPrepTimeMins(10);
        recipe.setCookingTimeMins(20);
        recipe.setServingSize(2);
        recipe.setIsCommunityPublished(true);
        return recipeRepository.save(recipe);
    }

    private Vault saveVault(User vaultOwner, VaultType vaultType, String name) {
        Vault vault = new Vault();
        vault.setOwnerId(vaultOwner.getUserId());
        vault.setVaultType(vaultType);
        vault.setName(name);
        return vaultRepository.save(vault);
    }

    private VaultFolder saveFolder(Vault vault, String name) {
        VaultFolder folder = new VaultFolder();
        folder.setVault(vault);
        folder.setFolderName(name);
        return vaultFolderRepository.save(folder);
    }

    private void addVaultMember(Vault vault, User user) {
        VaultMember member = new VaultMember();
        member.setVault(vault);
        member.setUser(user);
        vaultMemberRepository.save(member);
    }

    private void addRecipeToFolder(Recipe recipe, VaultFolder folder) {
        VaultFolderRecipe folderRecipe = new VaultFolderRecipe();
        folderRecipe.setRecipe(recipe);
        folderRecipe.setFolder(folder);
        vaultFolderRecipeRepository.save(folderRecipe);
    }

    private RecipeRequest recipeRequest(String title, String cuisine, Integer folderId) {
        return new RecipeRequest(
                title, "A description.", cuisine,
                10, 20, 2,
                null, null, null, false, folderId
        );
    }

    private RecipeFullRequest fullRequest(String title, String cuisine, Integer folderId, Integer ingId) {
        return new RecipeFullRequest(
                title, "A description.", cuisine,
                10, 20, 2,
                null, null, null, false,
                List.of(new RecipeIngredientRequest(ingId, new BigDecimal("1.5"), "cups", 1)),
                List.of(new RecipeStepRequest(1, "Mix everything.")),
                folderId
        );
    }

    private UsernamePasswordAuthenticationToken authAs(Integer userId) {
        return new UsernamePasswordAuthenticationToken(String.valueOf(userId), null, List.of());
    }

    // GET /recipes/all

    @Test
    void getAllRecipes_returns200_withOnlyAccessibleRecipes() throws Exception {
        saveRecipe(owner, "Owned Recipe");
        saveRecipe(otherUser, "Inaccessible Recipe");
        savePublishedRecipe(otherUser, "Community Recipe");

        Vault ownerVault = saveVault(owner, VaultType.SHARED, "Owner Shared Vault");
        VaultFolder ownerFolder = saveFolder(ownerVault, "Owner Folder");
        Recipe vaultOwnedRecipe = saveRecipe(otherUser, "Vault Owner Recipe");
        addRecipeToFolder(vaultOwnedRecipe, ownerFolder);

        Vault memberVault = saveVault(otherUser, VaultType.SHARED, "Member Shared Vault");
        VaultFolder memberFolder = saveFolder(memberVault, "Member Folder");
        Recipe sharedRecipe = saveRecipe(otherUser, "Shared Recipe");
        addVaultMember(memberVault, owner);
        addRecipeToFolder(sharedRecipe, memberFolder);

        mockMvc.perform(get("/recipes/all")
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(4)))
                .andExpect(jsonPath("$[*].title", hasItems(
                        "Owned Recipe",
                        "Community Recipe",
                        "Vault Owner Recipe",
                        "Shared Recipe"
                )));
    }

    @Test
    void getAllRecipes_returnsEachRecipeOnce_whenAccessibleInMultipleWays() throws Exception {
        Recipe recipe = savePublishedRecipe(owner, "Accessible Recipe");
        Vault sharedVault = saveVault(otherUser, VaultType.SHARED, "Shared Vault");
        VaultFolder sharedFolder = saveFolder(sharedVault, "Shared Folder");
        addVaultMember(sharedVault, owner);
        addRecipeToFolder(recipe, sharedFolder);

        mockMvc.perform(get("/recipes/all")
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].title", is("Accessible Recipe")));
    }

    // GET /recipes/community

    @Test
    void getCommunityRecipes_returns200_withOnlyPublished() throws Exception {
        saveRecipe(owner, "Private Recipe");
        savePublishedRecipe(owner, "Published Recipe");

        mockMvc.perform(get("/recipes/community")
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].title", is("Published Recipe")))
                .andExpect(jsonPath("$[0].isCommunityPublished", is(true)));
    }

    // GET /recipes/single/{id}

    @Test
    void getRecipeById_returns200_whenFound() throws Exception {
        Recipe recipe = saveRecipe(owner, "Findable Recipe");

        mockMvc.perform(get("/recipes/single/{id}", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.recipeId", is(recipe.getRecipeId())))
                .andExpect(jsonPath("$.title", is("Findable Recipe")))
                .andExpect(jsonPath("$.ownerId", is(owner.getUserId())))
                .andExpect(jsonPath("$.cuisineType", is(validCuisine)));
    }

    @Test
    void getRecipeById_returns404_whenNotFound() throws Exception {
        mockMvc.perform(get("/recipes/single/{id}", 999999)
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Recipe not found."));
    }

    @Test
    void getRecipeById_returns403_whenPrivateRecipeIsNotAccessible() throws Exception {
        Recipe recipe = saveRecipe(otherUser, "Private Recipe");

        mockMvc.perform(get("/recipes/single/{id}", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("You do not have permission to view this recipe."));
    }

    @Test
    void getRecipeById_returns200_whenCommunityPublished() throws Exception {
        Recipe recipe = savePublishedRecipe(otherUser, "Community Recipe");

        mockMvc.perform(get("/recipes/single/{id}", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title", is("Community Recipe")));
    }

    @Test
    void getRecipeById_returns200_whenUserIsSharedVaultMember() throws Exception {
        Vault sharedVault = saveVault(otherUser, VaultType.SHARED, "Shared Vault");
        VaultFolder sharedFolder = saveFolder(sharedVault, "Shared Folder");
        Recipe recipe = saveRecipe(otherUser, "Shared Recipe");
        addVaultMember(sharedVault, owner);
        addRecipeToFolder(recipe, sharedFolder);

        mockMvc.perform(get("/recipes/single/{id}", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title", is("Shared Recipe")));
    }

    @Test
    void getRecipeById_returns403_whenUserIsNotSharedVaultMember() throws Exception {
        Vault sharedVault = saveVault(otherUser, VaultType.SHARED, "Shared Vault");
        VaultFolder sharedFolder = saveFolder(sharedVault, "Shared Folder");
        Recipe recipe = saveRecipe(otherUser, "Shared Recipe");
        addRecipeToFolder(recipe, sharedFolder);

        mockMvc.perform(get("/recipes/single/{id}", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("You do not have permission to view this recipe."));
    }

    // POST /recipes/create

    @Test
    void createRecipe_returns200_andFilesRecipeIntoFolder() throws Exception {
        RecipeRequest request = recipeRequest("New Recipe", validCuisine, privateFolder.getFolderId());

        mockMvc.perform(post("/recipes/create")
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.recipeId", notNullValue()))
                .andExpect(jsonPath("$.title", is("New Recipe")))
                .andExpect(jsonPath("$.ownerId", is(owner.getUserId())));

        // Recipe row persisted.
        List<Recipe> saved = recipeRepository.findAll();
        org.junit.jupiter.api.Assertions.assertEquals(1, saved.size());

        org.junit.jupiter.api.Assertions.assertEquals(
                1,
                vaultFolderRecipeRepository.findByFolder_FolderId(privateFolder.getFolderId()).size()
        );
    }

    @Test
    void createRecipe_returns400_whenFolderIdMissing() throws Exception {
        RecipeRequest request = recipeRequest("No Folder", validCuisine, null);

        mockMvc.perform(post("/recipes/create")
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("A folder must be specified when creating a recipe."));
    }

    @Test
    void createRecipe_returns400_whenCuisineInvalid() throws Exception {
        RecipeRequest request = recipeRequest("Bad Cuisine", "not-a-real-cuisine", privateFolder.getFolderId());

        mockMvc.perform(post("/recipes/create")
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Cuisine type is invalid."));
    }

    @Test
    void createRecipe_returns400_whenTitleBlank() throws Exception {

        RecipeRequest request = recipeRequest("", validCuisine, privateFolder.getFolderId());

        mockMvc.perform(post("/recipes/create")
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void createRecipe_returns404_whenFolderNotFound() throws Exception {
        RecipeRequest request = recipeRequest("Ghost Folder", validCuisine, 999999);

        mockMvc.perform(post("/recipes/create")
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Folder not found."));
    }

    @Test
    void createRecipe_returns403_whenFolderNotInCallersPrivateVault() throws Exception {

        RecipeRequest request = recipeRequest("Not Yours", validCuisine, privateFolder.getFolderId());

        mockMvc.perform(post("/recipes/create")
                        .with(authentication(authAs(otherUser.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Recipes can only be added to a folder in your private vault."));
    }

    // POST /recipes/{sourceId}/copy

    @Test
    void copyRecipe_returns200_withIngredientsAndSteps() throws Exception {
        Recipe source = saveRecipe(owner, "Source Recipe");
        RecipeFullRequest request = fullRequest("Copied Recipe", validCuisine, privateFolder.getFolderId(), ingId);

        mockMvc.perform(post("/recipes/{sourceId}/copy", source.getRecipeId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.recipeId", notNullValue()))
                .andExpect(jsonPath("$.title", is("Copied Recipe")));

        org.junit.jupiter.api.Assertions.assertEquals(2, recipeRepository.findAll().size());
        org.junit.jupiter.api.Assertions.assertEquals(
                1,
                vaultFolderRecipeRepository.findByFolder_FolderId(privateFolder.getFolderId()).size()
        );
    }

    @Test
    void copyRecipe_returns404_whenSourceRecipeNotFound() throws Exception {
        RecipeFullRequest request = fullRequest("Copy Of Ghost", validCuisine, privateFolder.getFolderId(), ingId);

        mockMvc.perform(post("/recipes/{sourceId}/copy", 999999)
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Source recipe not found."));
    }

    @Test
    void copyRecipe_returns400_whenIngredientDoesNotExist() throws Exception {
        Recipe source = saveRecipe(owner, "Source Recipe");
        RecipeFullRequest request = fullRequest("Bad Ingredient", validCuisine, privateFolder.getFolderId(), 999999);

        mockMvc.perform(post("/recipes/{sourceId}/copy", source.getRecipeId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("One of the ingredients you want to add does not exist."));
    }

    // PUT /recipes/edit/{id}

    @Test
    void updateRecipe_returns200_whenOwner() throws Exception {
        Recipe recipe = saveRecipe(owner, "Old Title");
        RecipeRequest request = recipeRequest("New Title", validCuisine, null);

        mockMvc.perform(put("/recipes/edit/{id}", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title", is("New Title")));

        org.junit.jupiter.api.Assertions.assertEquals(
                "New Title",
                recipeRepository.findById(recipe.getRecipeId()).get().getTitle()
        );
    }

    @Test
    void updateRecipe_returns403_whenNotOwner() throws Exception {
        Recipe recipe = saveRecipe(owner, "Owner's Recipe");
        RecipeRequest request = recipeRequest("Hijacked", validCuisine, null);

        mockMvc.perform(put("/recipes/edit/{id}", recipe.getRecipeId())
                        .with(authentication(authAs(otherUser.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Only the owner of this recipe can edit it."));
    }

    @Test
    void updateRecipe_returns404_whenNotFound() throws Exception {
        RecipeRequest request = recipeRequest("Ghost", validCuisine, null);

        mockMvc.perform(put("/recipes/edit/{id}", 999999)
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Recipe not found."));
    }

    @Test
    void updateRecipe_returns400_whenCuisineInvalid() throws Exception {
        Recipe recipe = saveRecipe(owner, "Valid Recipe");
        RecipeRequest request = recipeRequest("Still Here", "not-a-real-cuisine", null);

        mockMvc.perform(put("/recipes/edit/{id}", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Cuisine type is invalid."));
    }

    // DELETE /recipes/delete/{id}

    @Test
    void deleteRecipe_returns200_andRemovesRow_whenOwner() throws Exception {
        Recipe recipe = saveRecipe(owner, "Doomed Recipe");

        mockMvc.perform(delete("/recipes/delete/{id}", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf()))
                .andExpect(status().isOk());

        org.junit.jupiter.api.Assertions.assertTrue(
                recipeRepository.findById(recipe.getRecipeId()).isEmpty()
        );
    }

    @Test
    void deleteRecipe_returns403_whenNotOwner() throws Exception {
        Recipe recipe = saveRecipe(owner, "Owner's Recipe");

        mockMvc.perform(delete("/recipes/delete/{id}", recipe.getRecipeId())
                        .with(authentication(authAs(otherUser.getUserId())))
                        .with(csrf()))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Only the owner of this recipe can delete it."));

        // Row still there.
        org.junit.jupiter.api.Assertions.assertTrue(
                recipeRepository.findById(recipe.getRecipeId()).isPresent()
        );
    }

    @Test
    void deleteRecipe_returns404_whenNotFound() throws Exception {
        mockMvc.perform(delete("/recipes/delete/{id}", 999999)
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf()))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Recipe not found."));
    }
}
