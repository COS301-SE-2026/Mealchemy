package com.mealchemy.swipes.integration;

import com.mealchemy.swipes.model.Swipe;
import com.mealchemy.swipes.repository.SwipeRepository;
import com.mealchemy.swipes.dto.SwipeRequest;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.shared.enums.SwipeAction;
import com.mealchemy.engine.dto.SignalScoresResponse;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.auth.model.User;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.List;
import java.time.OffsetDateTime;
import org.springframework.test.web.servlet.MvcResult;

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
public class SwipeControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private SwipeRepository swipeRepository;

    @Autowired
    private RecipeRepository recipeRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ObjectMapper objectMapper;

    private Integer USER_ID = 1;

    private Recipe recipe;

    @BeforeEach
    void setUp() {
        swipeRepository.deleteAll();
        recipeRepository.deleteAll();
        userRepository.deleteAll();

        User user = new User();
        user.setEmail("swipe-test-" + System.nanoTime() + "@example.com");
        user.setPasswordHash("hashed-password");
        user.setRoles(List.of("USER"));
        user = userRepository.save(user);
        USER_ID = user.getUserId();

        recipe = newRecipe(USER_ID, "Hummus Bowl", "MEDITERRANEAN");
    }

    private Recipe newRecipe(Integer ownerId, String title, String cuisineType) {
        Recipe r = new Recipe();
        r.setOwnerId(ownerId);
        r.setTitle(title);
        r.setDescription("A tasty recipe.");
        r.setCuisineType(cuisineType);
        r.setPrepTimeMins(10);
        r.setCookingTimeMins(20);
        r.setServingSize(2);
        r.setIsCommunityPublished(true);
        return recipeRepository.save(r);
    }

    private Swipe addSwipeRow(Integer userId, Integer recipeId, String cuisineValue, SwipeAction action) {
        Swipe swipe = new Swipe();
        swipe.setUserId(userId);
        swipe.setRecipeId(recipeId);
        swipe.setCuisineValue(cuisineValue);
        swipe.setAction(action);
        swipe.setWeightsSnapshot(new SignalScoresResponse(0.9, 0.8, 0.5, 0.3, 1.0));
        swipe.setFlushed(false);
        return swipeRepository.save(swipe);
    }

    private UsernamePasswordAuthenticationToken authAs(Integer userId) {
        return new UsernamePasswordAuthenticationToken(String.valueOf(userId), null, List.of());
    }

    // ========== recordSwipe ==========

    @Test
    void recordSwipe_returns200_andPersistsSwipe() throws Exception {
        SignalScoresResponse signalScores = new SignalScoresResponse(0.9, 0.8, 0.5, 0.3, 1.0);
        SwipeRequest request = new SwipeRequest(recipe.getRecipeId(), "ITALIAN", SwipeAction.LIKED, signalScores);

        mockMvc.perform(post("/discovery/swipes")
                        .with(authentication(authAs(USER_ID)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.recipe_id", is(recipe.getRecipeId())))
                .andExpect(jsonPath("$.action", is("LIKED")));

        List<Swipe> savedRows = swipeRepository.findByUserId(USER_ID);
        org.junit.jupiter.api.Assertions.assertEquals(1, savedRows.size());
        Swipe saved = savedRows.get(0);
        org.junit.jupiter.api.Assertions.assertEquals(recipe.getRecipeId(), saved.getRecipeId());
        org.junit.jupiter.api.Assertions.assertEquals("ITALIAN", saved.getCuisineValue());
        org.junit.jupiter.api.Assertions.assertEquals(SwipeAction.LIKED, saved.getAction());
        org.junit.jupiter.api.Assertions.assertEquals(Boolean.FALSE, saved.getFlushed());
        org.junit.jupiter.api.Assertions.assertNotNull(saved.getSwipedAt());
        org.junit.jupiter.api.Assertions.assertEquals(0.9, saved.getWeightsSnapshot().pantryMatch());
    }

    @Test
    void recordSwipe_returns400_whenRecipeIdMissing() throws Exception {
        String invalidBody = """
            {"cuisine_value":"ITALIAN","action":"LIKED","signal_scores":{"pantry_match":0.9,"cuisine":0.8,"nutrition":0.5,"freshness":0.3,"novelty":1.0}}
            """;

        mockMvc.perform(post("/discovery/swipes")
                        .with(authentication(authAs(USER_ID)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(invalidBody))
                .andExpect(status().isBadRequest());

        org.junit.jupiter.api.Assertions.assertTrue(swipeRepository.findByUserId(USER_ID).isEmpty());
    }

    @Test
    void recordSwipe_returns400_whenCuisineValueMissing() throws Exception {
        String invalidBody = """
            {"recipe_id":100,"action":"LIKED","signal_scores":{"pantry_match":0.9,"cuisine":0.8,"nutrition":0.5,"freshness":0.3,"novelty":1.0}}
            """;

        mockMvc.perform(post("/discovery/swipes")
                        .with(authentication(authAs(USER_ID)))
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(invalidBody))
                .andExpect(status().isBadRequest());
    }

    // ========== getLikedRecipes ==========

    @Test
    void getLikedRecipes_returns200_withLikedList() throws Exception {
        addSwipeRow(USER_ID, recipe.getRecipeId(), "MEDITERRANEAN", SwipeAction.LIKED);

        mockMvc.perform(get("/discovery/liked")
                        .with(authentication(authAs(USER_ID))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.liked_recipes", hasSize(1)))
                .andExpect(jsonPath("$.liked_recipes[0].recipe_id", is(recipe.getRecipeId())))
                .andExpect(jsonPath("$.liked_recipes[0].recipe.title", is("Hummus Bowl")))
                .andExpect(jsonPath("$.liked_recipes[0].liked_at", notNullValue()));
    }

    @Test
    void getLikedRecipes_returns200_withEmptyList_whenNoLikes() throws Exception {
        mockMvc.perform(get("/discovery/liked")
                        .with(authentication(authAs(USER_ID))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.liked_recipes", hasSize(0)));
    }

    @Test
    void getLikedRecipes_excludesDislikedAndSkippedSwipes() throws Exception {
        Recipe dislikedRecipe = newRecipe(USER_ID, "Spicy Ramen", "JAPANESE");
        Recipe skippedRecipe = newRecipe(USER_ID, "Caesar Salad", "AMERICAN");

        addSwipeRow(USER_ID, recipe.getRecipeId(), "MEDITERRANEAN", SwipeAction.LIKED);
        addSwipeRow(USER_ID, dislikedRecipe.getRecipeId(), "JAPANESE", SwipeAction.DISLIKED);
        addSwipeRow(USER_ID, skippedRecipe.getRecipeId(), "AMERICAN", SwipeAction.SKIPPED);

        mockMvc.perform(get("/discovery/liked")
                        .with(authentication(authAs(USER_ID))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.liked_recipes", hasSize(1)))
                .andExpect(jsonPath("$.liked_recipes[0].recipe_id", is(recipe.getRecipeId())));
    }

    @Test
    void getLikedRecipes_returnsOnlyMostRecentSwipe_whenSameRecipeLikedTwice() throws Exception {
        addSwipeRow(USER_ID, recipe.getRecipeId(), "MEDITERRANEAN", SwipeAction.LIKED);
        Thread.sleep(50);
        Swipe mostRecent = addSwipeRow(USER_ID, recipe.getRecipeId(), "MEDITERRANEAN", SwipeAction.LIKED);

        MvcResult result = mockMvc.perform(get("/discovery/liked")
                        .with(authentication(authAs(USER_ID))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.liked_recipes", hasSize(1)))
                .andExpect(jsonPath("$.liked_recipes[0].recipe_id", is(recipe.getRecipeId())))
                .andReturn();

        String json = result.getResponse().getContentAsString();
        String likedAtStr = com.jayway.jsonpath.JsonPath.read(json, "$.liked_recipes[0].liked_at");
        org.junit.jupiter.api.Assertions.assertEquals(
            mostRecent.getSwipedAt().toInstant(),
            OffsetDateTime.parse(likedAtStr).toInstant()
        );
    }

    @Test
    void getLikedRecipes_excludesSwipe_whenRecipeNoLongerExists() throws Exception {
        Recipe deletedRecipe = newRecipe(USER_ID, "Deleted Dish", "FRENCH");
        addSwipeRow(USER_ID, recipe.getRecipeId(), "MEDITERRANEAN", SwipeAction.LIKED);
        addSwipeRow(USER_ID, deletedRecipe.getRecipeId(), "FRENCH", SwipeAction.LIKED);

        recipeRepository.delete(deletedRecipe);

        mockMvc.perform(get("/discovery/liked")
                        .with(authentication(authAs(USER_ID))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.liked_recipes", hasSize(1)))
                .andExpect(jsonPath("$.liked_recipes[0].recipe_id", is(recipe.getRecipeId())));
    }

    @Test
    void getLikedRecipes_doesNotReturnAnotherUsersLikes() throws Exception {
        User otherUser = new User();
        otherUser.setEmail("swipe-other-" + System.nanoTime() + "@example.com");
        otherUser.setPasswordHash("hashed-password");
        otherUser.setRoles(List.of("USER"));
        otherUser = userRepository.save(otherUser);
        Integer otherUserId = otherUser.getUserId();
        addSwipeRow(otherUserId, recipe.getRecipeId(), "MEDITERRANEAN", SwipeAction.LIKED);

        mockMvc.perform(get("/discovery/liked")
                        .with(authentication(authAs(USER_ID))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.liked_recipes", hasSize(0)));
    }
}