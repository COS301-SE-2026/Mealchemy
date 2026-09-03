package com.mealchemy.recipe.integration;

import com.mealchemy.auth.model.User;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.recipe.dto.RecipeStepRequest;
import com.mealchemy.recipe.dto.RecipeStepReorderRequest;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.model.RecipeStep;
import com.mealchemy.recipe.repository.RecipeStepRepository;
import com.mealchemy.recipe.repository.RecipeRepository;
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
import org.springframework.http.MediaType;

import static org.hamcrest.Matchers.contains;
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
public class RecipeStepControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private RecipeStepRepository recipeStepRepository;

    @Autowired
    private RecipeRepository recipeRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ObjectMapper objectMapper;

    private static final String VALID_CUISINE = "ITALIAN";

    private User owner;
    private User otherUser;
    private Recipe recipe;

    @BeforeEach
    void setUp() {
        
        recipeStepRepository.deleteAll();
        recipeRepository.deleteAll();
        userRepository.deleteAll();

        owner = newUser("owner@gmail.com");
        otherUser = newUser("other@gmail.com");

        recipe = saveRecipe(owner, "Base Recipe");
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


    private RecipeStep saveStepRow(Recipe recipe, int stepNr, String content) {
        RecipeStep step = new RecipeStep();
        step.setRecipe(recipe);
        step.setStepNr(stepNr);
        step.setContent(content);
        return recipeStepRepository.save(step);
    }

    private RecipeStepRequest stepRequest(int stepNr, String content) {
        return new RecipeStepRequest(stepNr, content);
    }

    private UsernamePasswordAuthenticationToken authAs(Integer userId) {
        return new UsernamePasswordAuthenticationToken(String.valueOf(userId), null, List.of());
    }

    // GET /steps/recipe/{recipeId}

    @Test
    void getStepsByRecipeId_returns200_orderedByStepNr() throws Exception {
       
        saveStepRow(recipe, 2, "Second step.");
        saveStepRow(recipe, 1, "First step.");

        mockMvc.perform(get("/steps/recipe/{recipeId}", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].stepNr", is(1)))
                .andExpect(jsonPath("$[0].content", is("First step.")))
                .andExpect(jsonPath("$[1].stepNr", is(2)));
    }

    @Test
    void getStepsByRecipeId_returnsEmptyList_whenRecipeHasNone() throws Exception {
        mockMvc.perform(get("/steps/recipe/{recipeId}", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));
    }

    // POST /steps/recipe/{recipeId}/step/create

    @Test
    void createStep_returns200_andPersistsRow() throws Exception {
        RecipeStepRequest request = stepRequest(1, "Mix everything.");

        mockMvc.perform(post("/steps/recipe/{recipeId}/step/create", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.stepId", notNullValue()))
                .andExpect(jsonPath("$.recipeId", is(recipe.getRecipeId())))
                .andExpect(jsonPath("$.stepNr", is(1)))
                .andExpect(jsonPath("$.content", is("Mix everything.")));

        List<RecipeStep> rows = recipeStepRepository.findByRecipe_RecipeIdOrderByStepNrAsc(recipe.getRecipeId());
        org.junit.jupiter.api.Assertions.assertEquals(1, rows.size());
        org.junit.jupiter.api.Assertions.assertEquals("Mix everything.", rows.get(0).getContent());
    }

    @Test
    void createStep_returns404_whenRecipeNotFound() throws Exception {
        RecipeStepRequest request = stepRequest(1, "Mix everything.");

        mockMvc.perform(post("/steps/recipe/{recipeId}/step/create", 999999)
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Recipe not found."));
    }

    @Test
    void createStep_returns403_whenNotOwner() throws Exception {
        RecipeStepRequest request = stepRequest(1, "Mix everything.");

        mockMvc.perform(post("/steps/recipe/{recipeId}/step/create", recipe.getRecipeId())
                        .with(authentication(authAs(otherUser.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Only the owner of this recipe can modify its steps."));
    }

    @Test
    void createStep_returns400_whenContentBlank() throws Exception {
        
        RecipeStepRequest request = stepRequest(1, "");

        mockMvc.perform(post("/steps/recipe/{recipeId}/step/create", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void createStep_returns400_whenStepNrBelowMinimum() throws Exception {
       
        RecipeStepRequest request = stepRequest(0, "Mix everything.");

        mockMvc.perform(post("/steps/recipe/{recipeId}/step/create", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }

    // PUT /steps/recipe/{recipeId}/step/{id}/edit

    @Test
    void updateStep_returns200_whenOwner() throws Exception {
        RecipeStep row = saveStepRow(recipe, 1, "Old content.");
        RecipeStepRequest request = stepRequest(3, "New content.");

        mockMvc.perform(put("/steps/recipe/{recipeId}/step/{id}/edit", recipe.getRecipeId(), row.getStepId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.stepNr", is(3)))
                .andExpect(jsonPath("$.content", is("New content.")));

        RecipeStep reloaded = recipeStepRepository.findById(row.getStepId()).get();
        org.junit.jupiter.api.Assertions.assertEquals(3, reloaded.getStepNr());
        org.junit.jupiter.api.Assertions.assertEquals("New content.", reloaded.getContent());
    }

    @Test
    void updateStep_returns404_whenRecipeNotFound() throws Exception {
        RecipeStepRequest request = stepRequest(1, "New content.");

        mockMvc.perform(put("/steps/recipe/{recipeId}/step/{id}/edit", 999999, 123)
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Recipe not found."));
    }

    @Test
    void updateStep_returns403_whenNotOwner() throws Exception {
        RecipeStep row = saveStepRow(recipe, 1, "Old content.");
        RecipeStepRequest request = stepRequest(2, "New content.");

        mockMvc.perform(put("/steps/recipe/{recipeId}/step/{id}/edit", recipe.getRecipeId(), row.getStepId())
                        .with(authentication(authAs(otherUser.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Only the owner of this recipe can modify its steps."));
    }

    @Test
    void updateStep_returns404_whenStepNotFound() throws Exception {
        RecipeStepRequest request = stepRequest(1, "New content.");

        mockMvc.perform(put("/steps/recipe/{recipeId}/step/{id}/edit", recipe.getRecipeId(), 999999)
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Step not found."));
    }

    @Test
    void updateStep_returns403_whenStepBelongsToDifferentRecipe() throws Exception {
        Recipe otherRecipe = saveRecipe(owner, "Other Recipe");
        RecipeStep rowOnOther = saveStepRow(otherRecipe, 1, "Belongs elsewhere.");
        RecipeStepRequest request = stepRequest(2, "New content.");

        mockMvc.perform(put("/steps/recipe/{recipeId}/step/{id}/edit", recipe.getRecipeId(), rowOnOther.getStepId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Step must be part of the recipe."));
    }

    // PUT /steps/recipe/{recipeId}/reorder

    @Test
    void reorderSteps_returns200_andRenumbersInGivenOrder() throws Exception {
        RecipeStep first = saveStepRow(recipe, 1, "Step A.");
        RecipeStep second = saveStepRow(recipe, 2, "Step B.");
        RecipeStep third = saveStepRow(recipe, 3, "Step C.");

        // Reverse the order: C, B, A.
        RecipeStepReorderRequest request = new RecipeStepReorderRequest(
                List.of(third.getStepId(), second.getStepId(), first.getStepId())
        );

        mockMvc.perform(put("/steps/recipe/{recipeId}/reorder", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(3)))
                .andExpect(jsonPath("$[*].content", contains("Step C.", "Step B.", "Step A.")))
                .andExpect(jsonPath("$[0].stepNr", is(1)))
                .andExpect(jsonPath("$[1].stepNr", is(2)))
                .andExpect(jsonPath("$[2].stepNr", is(3)));

        org.junit.jupiter.api.Assertions.assertEquals(3, recipeStepRepository.findById(first.getStepId()).get().getStepNr());
        org.junit.jupiter.api.Assertions.assertEquals(1, recipeStepRepository.findById(third.getStepId()).get().getStepNr());
    }

    @Test
    void reorderSteps_returns404_whenRecipeNotFound() throws Exception {
        RecipeStepReorderRequest request = new RecipeStepReorderRequest(List.of(1, 2));

        mockMvc.perform(put("/steps/recipe/{recipeId}/reorder", 999999)
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Recipe not found."));
    }

    @Test
    void reorderSteps_returns403_whenNotOwner() throws Exception {
        RecipeStep first = saveStepRow(recipe, 1, "Step A.");
        RecipeStep second = saveStepRow(recipe, 2, "Step B.");
        RecipeStepReorderRequest request = new RecipeStepReorderRequest(
                List.of(second.getStepId(), first.getStepId())
        );

        mockMvc.perform(put("/steps/recipe/{recipeId}/reorder", recipe.getRecipeId())
                        .with(authentication(authAs(otherUser.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Only the owner of the recipe can manipulate the order of the steps."));
    }

    @Test
    void reorderSteps_returns400_whenIdsDoNotMatchExistingSteps() throws Exception {
        saveStepRow(recipe, 1, "Step A.");
        saveStepRow(recipe, 2, "Step B.");

        RecipeStepReorderRequest request = new RecipeStepReorderRequest(List.of(999998, 999999));

        mockMvc.perform(put("/steps/recipe/{recipeId}/reorder", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Provided step IDs must match the recipe's existing step."));
    }

    @Test
    void reorderSteps_returns400_whenIdCountDiffers() throws Exception {
        RecipeStep first = saveStepRow(recipe, 1, "Step A.");
        saveStepRow(recipe, 2, "Step B.");

        RecipeStepReorderRequest request = new RecipeStepReorderRequest(List.of(first.getStepId()));

        mockMvc.perform(put("/steps/recipe/{recipeId}/reorder", recipe.getRecipeId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Provided step IDs must match the recipe's existing step."));
    }

    // DELETE /steps/recipe/{recipeId}/step/{id}/delete

    @Test
    void deleteStep_returns204_andRemovesRow_whenOwner() throws Exception {
        RecipeStep row = saveStepRow(recipe, 1, "Doomed step.");

        mockMvc.perform(delete("/steps/recipe/{recipeId}/step/{id}/delete", recipe.getRecipeId(), row.getStepId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf()))
                .andExpect(status().isNoContent());

        org.junit.jupiter.api.Assertions.assertTrue(
                recipeStepRepository.findById(row.getStepId()).isEmpty()
        );
    }

    @Test
    void deleteStep_returns404_whenRecipeNotFound() throws Exception {
        mockMvc.perform(delete("/steps/recipe/{recipeId}/step/{id}/delete", 999999, 123)
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf()))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Recipe not found."));
    }

    @Test
    void deleteStep_returns403_whenNotOwner() throws Exception {
        RecipeStep row = saveStepRow(recipe, 1, "Owner's step.");

        mockMvc.perform(delete("/steps/recipe/{recipeId}/step/{id}/delete", recipe.getRecipeId(), row.getStepId())
                        .with(authentication(authAs(otherUser.getUserId())))
                        .with(csrf()))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Only the owner of this recipe can modify its steps."));

        org.junit.jupiter.api.Assertions.assertTrue(
                recipeStepRepository.findById(row.getStepId()).isPresent()
        );
    }

    @Test
    void deleteStep_returns404_whenStepNotFound() throws Exception {
        mockMvc.perform(delete("/steps/recipe/{recipeId}/step/{id}/delete", recipe.getRecipeId(), 999999)
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf()))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Step not found."));
    }

    @Test
    void deleteStep_returns403_whenStepBelongsToDifferentRecipe() throws Exception {
        Recipe otherRecipe = saveRecipe(owner, "Other Recipe");
        RecipeStep rowOnOther = saveStepRow(otherRecipe, 1, "Belongs elsewhere.");

        mockMvc.perform(delete("/steps/recipe/{recipeId}/step/{id}/delete", recipe.getRecipeId(), rowOnOther.getStepId())
                        .with(authentication(authAs(owner.getUserId())))
                        .with(csrf()))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Step must be part of the recipe."));

        org.junit.jupiter.api.Assertions.assertTrue(
                recipeStepRepository.findById(rowOnOther.getStepId()).isPresent()
        );
    }
}
