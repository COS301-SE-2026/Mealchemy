package com.mealchemy.recipe.integration;
// model
import com.mealchemy.auth.model.User;
import com.mealchemy.profile.model.UserProfile;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.model.RecipeIngredient;
// repository
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.recipe.repository.RecipeIngredientRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.profile.repository.UserProfileRepository;
// dto
import com.mealchemy.recipe.dto.RecipeIngredientRequest;

import com.mealchemy.shared.enums.PreferredUnit;
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
public class RecipeIngredientControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private RecipeIngredientRepository recipeIngredientRepository;

    @Autowired
    private RecipeRepository recipeRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private IngredientCatalogueRepository ingredientCatalogueRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserProfileRepository userProfileRepository;

    private static final String VALID_CUISINE = "italian";

    private User owner;
    private User otherUser;
    private Recipe recipe;
    private Integer ingId;
    private Integer otherIngId;
    private String ingName;
    private String otherIngName;

    @BeforeEach
    void setUp() {

        recipeIngredientRepository.deleteAll();
        recipeRepository.deleteAll();
        userRepository.deleteAll();

        owner = newUser("owner@gmail.com");
        otherUser = newUser("other@gmail.com");

        recipe = saveRecipe(owner, "Base Recipe");


        var seeded = ingredientCatalogueRepository.findAll();
        var first = seeded.stream()
                .filter(i -> "Kale, raw".equals(i.getName()))
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("Seeded ingredient 'Kale, raw' not found"));
        var second = seeded.stream()
                .filter(i -> "Broccoli, raw".equals(i.getName()))
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("Seeded ingredient 'Broccoli, raw' not found"));
        ingId = first.getIngId();
        otherIngId = second.getIngId();
        ingName = first.getName();
        otherIngName = second.getName();

        UserProfile ownerProfile = new UserProfile();
        ownerProfile.setUserId(owner.getUserId());
        ownerProfile.setPreferredUnit(PreferredUnit.METRIC);
        userProfileRepository.save(ownerProfile);

        UserProfile otherProfile = new UserProfile();
        otherProfile.setUserId(otherUser.getUserId());
        otherProfile.setPreferredUnit(PreferredUnit.METRIC);
        userProfileRepository.save(otherProfile);
    }

    private User newUser(String email) {
        User user = new User();
        user.setEmail(email);
        user.setPasswordHash("hashed-password");
        user.setRoles(List.of("USER"));
        return userRepository.save(user);
    }

    private Recipe saveRecipe(User owner, String title) {
        Recipe recipe = new Recipe();
        recipe.setOwnerId(owner.getUserId());
        recipe.setTitle(title);
        recipe.setDescription("A description.");
        recipe.setCuisineType(VALID_CUISINE);
        recipe.setPrepTimeMins(10);
        recipe.setCookingTimeMins(20);
        recipe.setServingSize(2);
        recipe.setIsCommunityPublished(false);
        return recipeRepository.save(recipe);
    }


    private RecipeIngredient saveIngredientRow(Recipe recipe, Integer ingId, String unit, int sortOrder) {
        RecipeIngredient row = new RecipeIngredient();
        row.setRecipe(recipe);
        row.setIngId(ingId);
        row.setQuantity(new BigDecimal("2.0"));
        row.setUnit(unit);
        row.setSortOrder(sortOrder);
        return recipeIngredientRepository.save(row);
    }

    private RecipeIngredientRequest ingredientRequest(Integer ingId, String unit, int sortOrder) {
        return new RecipeIngredientRequest(ingId, new BigDecimal("1.5"), unit, sortOrder);
    }

    private UsernamePasswordAuthenticationToken authAs(Integer userId) {
        return new UsernamePasswordAuthenticationToken(String.valueOf(userId), null, List.of());
    }

    // GET /ingredients/recipe/{recipeId}

    @Test
    void getIngredientsByRecipeId_returns200_withResolvedNames() throws Exception {
        saveIngredientRow(recipe, ingId, "cups", 1);
        saveIngredientRow(recipe, otherIngId, "grams", 2);

        mockMvc.perform(get("/ingredients/recipe/{recipeId}", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].recipeId", is(recipe.getRecipeId())))
                .andExpect(jsonPath("$[0].ingName", is(ingName)))
                .andExpect(jsonPath("$[1].ingName", is(otherIngName)));
    }

    @Test
    void getIngredientsByRecipeId_returnsEmptyList_whenRecipeHasNone() throws Exception {
        mockMvc.perform(get("/ingredients/recipe/{recipeId}", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));
    }

    // POST /ingredients/recipe/{recipeId}/ingredient/create

    @Test
    void createIngredient_returns200_andPersistsRow() throws Exception {
        RecipeIngredientRequest request = ingredientRequest(ingId, "cups", 1);

        mockMvc.perform(post("/ingredients/recipe/{recipeId}/ingredient/create", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.ingredientId", notNullValue()))
                .andExpect(jsonPath("$.recipeId", is(recipe.getRecipeId())))
                .andExpect(jsonPath("$.ingId", is(ingId)))
                .andExpect(jsonPath("$.ingName", is(ingName)))
                .andExpect(jsonPath("$.unit", is("cups")));

        List<RecipeIngredient> rows = recipeIngredientRepository.findByRecipe_RecipeId(recipe.getRecipeId());
        org.junit.jupiter.api.Assertions.assertEquals(1, rows.size());
        org.junit.jupiter.api.Assertions.assertEquals(ingId.intValue(), rows.get(0).getIngId());
    }

    @Test
    void createIngredient_returns404_whenRecipeNotFound() throws Exception {
        RecipeIngredientRequest request = ingredientRequest(ingId, "cups", 1);

        mockMvc.perform(post("/ingredients/recipe/{recipeId}/ingredient/create", 999999)
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Recipe not found."));
    }

    @Test
    void createIngredient_returns403_whenNotOwner() throws Exception {
        RecipeIngredientRequest request = ingredientRequest(ingId, "cups", 1);

        mockMvc.perform(post("/ingredients/recipe/{recipeId}/ingredient/create", recipe.getRecipeId())
                        .with(authentication(authAs(otherUser.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Only the owner of this recipe can modify its ingredients."));
    }

    @Test
    void createIngredient_returns400_whenIngredientDoesNotExist() throws Exception {
        RecipeIngredientRequest request = ingredientRequest(999999, "cups", 1);

        mockMvc.perform(post("/ingredients/recipe/{recipeId}/ingredient/create", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("The ingredient you want to add does not exist."));
    }

    @Test
    void createIngredient_returns400_whenUnitBlank() throws Exception {
        
        RecipeIngredientRequest request = ingredientRequest(ingId, "", 1);

        mockMvc.perform(post("/ingredients/recipe/{recipeId}/ingredient/create", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }

    // PUT /ingredients/recipe/{recipeId}/ingredient/{id}/edit

    @Test
    void updateIngredient_returns200_whenOwner() throws Exception {
        RecipeIngredient row = saveIngredientRow(recipe, ingId, "cups", 1);
        RecipeIngredientRequest request = ingredientRequest(otherIngId, "grams", 1);

        mockMvc.perform(put("/ingredients/recipe/{recipeId}/ingredient/{id}/edit", recipe.getRecipeId(), row.getIngredientId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.ingId", is(otherIngId)))
                .andExpect(jsonPath("$.ingName", is(otherIngName)))
                .andExpect(jsonPath("$.unit", is("grams")));

        RecipeIngredient reloaded = recipeIngredientRepository.findById(row.getIngredientId()).get();
        org.junit.jupiter.api.Assertions.assertEquals(otherIngId.intValue(), reloaded.getIngId());
        org.junit.jupiter.api.Assertions.assertEquals("grams", reloaded.getUnit());
    }

    @Test
    void updateIngredient_returns404_whenRecipeNotFound() throws Exception {
        RecipeIngredientRequest request = ingredientRequest(ingId, "cups", 1);

        mockMvc.perform(put("/ingredients/recipe/{recipeId}/ingredient/{id}/edit", 999999, 123)
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Recipe not found."));
    }

    @Test
    void updateIngredient_returns403_whenNotOwner() throws Exception {
        RecipeIngredient row = saveIngredientRow(recipe, ingId, "cups", 1);
        RecipeIngredientRequest request = ingredientRequest(otherIngId, "grams", 1);

        mockMvc.perform(put("/ingredients/recipe/{recipeId}/ingredient/{id}/edit", recipe.getRecipeId(), row.getIngredientId())
                        .with(authentication(authAs(otherUser.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Only the owner of this recipe can modify its ingredients."));
    }

    @Test
    void updateIngredient_returns404_whenIngredientNotFound() throws Exception {
        RecipeIngredientRequest request = ingredientRequest(ingId, "cups", 1);

        mockMvc.perform(put("/ingredients/recipe/{recipeId}/ingredient/{id}/edit", recipe.getRecipeId(), 999999)
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Ingredient not found."));
    }

    @Test
    void updateIngredient_returns403_whenIngredientBelongsToDifferentRecipe() throws Exception {

        Recipe otherRecipe = saveRecipe(owner, "Other Recipe");
        RecipeIngredient rowOnOther = saveIngredientRow(otherRecipe, ingId, "cups", 1);
        RecipeIngredientRequest request = ingredientRequest(otherIngId, "grams", 1);

        mockMvc.perform(put("/ingredients/recipe/{recipeId}/ingredient/{id}/edit", recipe.getRecipeId(), rowOnOther.getIngredientId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Ingredient must be part of the recipe."));
    }

    @Test
    void updateIngredient_returns400_whenNewIngredientDoesNotExist() throws Exception {
        RecipeIngredient row = saveIngredientRow(recipe, ingId, "cups", 1);
        RecipeIngredientRequest request = ingredientRequest(999999, "grams", 1);

        mockMvc.perform(put("/ingredients/recipe/{recipeId}/ingredient/{id}/edit", recipe.getRecipeId(), row.getIngredientId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("The ingredient you want to change to does not exist."));
    }

    // DELETE /ingredients/recipe/{recipeId}/ingredient/{id}/delete

    @Test
    void deleteIngredient_returns204_andRemovesRow_whenOwner() throws Exception {
        RecipeIngredient row = saveIngredientRow(recipe, ingId, "cups", 1);

        mockMvc.perform(delete("/ingredients/recipe/{recipeId}/ingredient/{id}/delete", recipe.getRecipeId(), row.getIngredientId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf()))
                .andExpect(status().isNoContent());

        org.junit.jupiter.api.Assertions.assertTrue(
                recipeIngredientRepository.findById(row.getIngredientId()).isEmpty()
        );
    }

    @Test
    void deleteIngredient_returns404_whenRecipeNotFound() throws Exception {
        mockMvc.perform(delete("/ingredients/recipe/{recipeId}/ingredient/{id}/delete", 999999, 123)
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf()))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Recipe not found."));
    }

    @Test
    void deleteIngredient_returns403_whenNotOwner() throws Exception {
        RecipeIngredient row = saveIngredientRow(recipe, ingId, "cups", 1);

        mockMvc.perform(delete("/ingredients/recipe/{recipeId}/ingredient/{id}/delete", recipe.getRecipeId(), row.getIngredientId())
                        .with(authentication(authAs(otherUser.getUserId())))
                        .with(csrf()))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Only the owner of this recipe can modify its ingredients."));

        org.junit.jupiter.api.Assertions.assertTrue(
                recipeIngredientRepository.findById(row.getIngredientId()).isPresent()
        );
    }

    @Test
    void deleteIngredient_returns404_whenIngredientNotFound() throws Exception {
        mockMvc.perform(delete("/ingredients/recipe/{recipeId}/ingredient/{id}/delete", recipe.getRecipeId(), 999999)
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf()))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Ingredient not found."));
    }

    @Test
    void deleteIngredient_returns403_whenIngredientBelongsToDifferentRecipe() throws Exception {
        Recipe otherRecipe = saveRecipe(owner, "Other Recipe");
        RecipeIngredient rowOnOther = saveIngredientRow(otherRecipe, ingId, "cups", 1);

        mockMvc.perform(delete("/ingredients/recipe/{recipeId}/ingredient/{id}/delete", recipe.getRecipeId(), rowOnOther.getIngredientId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf()))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Ingredient must be part of the recipe."));

        org.junit.jupiter.api.Assertions.assertTrue(
                recipeIngredientRepository.findById(rowOnOther.getIngredientId()).isPresent()
        );
    }
}
