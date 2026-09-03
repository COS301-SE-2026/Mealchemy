package com.mealchemy.swipes.controller;

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
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;

import java.time.OffsetDateTime;
import java.util.List;

import com.mealchemy.config.JwtUtil;
import com.mealchemy.config.WithMockJwtUser;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import com.fasterxml.jackson.databind.ObjectMapper;

/* Import classes */
import com.mealchemy.swipes.service.SwipeService;
import com.mealchemy.swipes.model.Swipe;
import com.mealchemy.swipes.dto.SwipeRequest;
import com.mealchemy.swipes.dto.LikedRecipeItem;
import com.mealchemy.shared.enums.SwipeAction;
import com.mealchemy.engine.dto.SignalScoresResponse;
import com.mealchemy.recipe.dto.RecipeResponse;

@ExtendWith(SpringExtension.class)
@WebMvcTest(SwipeController.class)
@WithMockJwtUser(userId = "1")
public class SwipeControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private JwtUtil jwtUtil;

    @MockitoBean
    private SwipeService swipeService;

    @Autowired
    private ObjectMapper objectMapper;

    private SwipeRequest request;
    private Swipe savedSwipe;

    @BeforeEach
    void setUp()
    {
        SignalScoresResponse signalScores = new SignalScoresResponse(0.9, 0.8, 0.5, 0.3, 1.0);
        request = new SwipeRequest(100, "ITALIAN", SwipeAction.LIKED, signalScores);

        savedSwipe = new Swipe();
        savedSwipe.setUserId(1);
        savedSwipe.setRecipeId(100);
        savedSwipe.setCuisineValue("ITALIAN");
        savedSwipe.setAction(SwipeAction.LIKED);
        savedSwipe.setWeightsSnapshot(signalScores);
    }

    // ========== recordSwipe ==========

    @Test
    void recordSwipe_returns200_withRecordedSwipe() throws Exception
    {
        when(swipeService.recordSwipe(eq(1), eq(100), eq("ITALIAN"), eq(SwipeAction.LIKED), any(SignalScoresResponse.class)))
            .thenReturn(savedSwipe);

        mockMvc.perform(post("/discovery/swipes")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.recipe_id").value(100))
            .andExpect(jsonPath("$.action").value("LIKED"));
    }

    @Test
    void recordSwipe_returns400_whenRecipeIdMissing() throws Exception
    {
        String invalidBody = """
            {"cuisine_value":"ITALIAN","action":"LIKED","signal_scores":{"pantry_match":0.9,"cuisine":0.8,"nutrition":0.5,"freshness":0.3,"novelty":1.0}}
            """;

        mockMvc.perform(post("/discovery/swipes")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(invalidBody))
            .andExpect(status().isBadRequest());
    }

    // ========== getLikedRecipes ==========

    @Test
    void getLikedRecipes_returns200_withLikedList() throws Exception
    {
        RecipeResponse recipe = new RecipeResponse(
            100, 5, "Hummus Bowl", "A tasty bowl.", "MEDITERRANEAN",
            10, 0, 2, null, null, null, true, null, null, null
        );
        LikedRecipeItem item = new LikedRecipeItem(100, "ITALIAN", OffsetDateTime.parse("2026-08-01T12:00:00Z"), recipe);

        when(swipeService.getLikedRecipes(1)).thenReturn(List.of(item));

        mockMvc.perform(get("/discovery/liked"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.liked_recipes[0].recipe_id").value(100))
            .andExpect(jsonPath("$.liked_recipes[0].recipe.title").value("Hummus Bowl"));
    }

    @Test
    void getLikedRecipes_returns200_withEmptyList_whenNoLikes() throws Exception
    {
        when(swipeService.getLikedRecipes(1)).thenReturn(List.of());

        mockMvc.perform(get("/discovery/liked"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.liked_recipes").isEmpty());
    }
}