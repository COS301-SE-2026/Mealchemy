package com.mealchemy.engine.controller;

/* Import libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import com.mealchemy.config.JwtUtil;
import com.mealchemy.config.WithMockJwtUser;

import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/* Import classes */
import com.mealchemy.engine.service.RecommendationService;
import com.mealchemy.engine.dto.EnrichedRecommendationResponse;
import com.mealchemy.engine.dto.EnrichedRecommendationItem;
import com.mealchemy.engine.dto.SignalScoresResponse;
import com.mealchemy.recipe.dto.RecipeResponse;
import com.mealchemy.engine.dto.RecommendationFilters;
import com.mealchemy.engine.dto.SignalHighlightResponse;

@ExtendWith(SpringExtension.class)
@WebMvcTest(RecommendationController.class)
@WithMockJwtUser(userId = "1")
public class RecommendationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private JwtUtil jwtUtil;

    @MockitoBean
    private RecommendationService recommendationService;

    private EnrichedRecommendationResponse response;

    @BeforeEach
    void setUp()
    {
        RecipeResponse recipe = new RecipeResponse(
            100, 1, "Hummus Bowl", "A tasty bowl.", "MEDITERRANEAN",
            10, 0, 2, null, null, null, true, null, null, null
        );

        EnrichedRecommendationItem item = new EnrichedRecommendationItem(
            100, "MEDITERRANEAN", new BigDecimal("0.87"),
            new SignalScoresResponse(0.9, 0.8, 0.5, 0.3, 1.0),
            2, List.of("parmesan", "basil"),
            List.of(
                new SignalHighlightResponse("pantry_match", 90, "Matched 8 of 9 ingredients you already have on hand."),
                new SignalHighlightResponse("cuisine", 80, "You've consistently enjoyed MEDITERRANEAN recipes.")
            ),
            recipe
        );

        response = new EnrichedRecommendationResponse(
            List.of(item), Map.of("MEDITERRANEAN", 1), 1, 1
        );
    }

    @Test
    void getRecommendations_returns200_withEnrichedList() throws Exception
    {
        when(recommendationService.getRecommendations(eq(1), isNull(), isNull(), isNull(), eq(RecommendationFilters.none()))).thenReturn(response);

        mockMvc.perform(get("/discovery/recommendations"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.recommendations[0].recipeId").value(100))
            .andExpect(jsonPath("$.recommendations[0].recipe.title").value("Hummus Bowl"))
            .andExpect(jsonPath("$.recommendations[0].missingIngredients[0]").value("parmesan"));
    }

    @Test
    void getRecommendations_returns200_withEmptyPool() throws Exception
    {
        EnrichedRecommendationResponse empty = EnrichedRecommendationResponse.empty();
        when(recommendationService.getRecommendations(eq(1), isNull(), isNull(), isNull(), eq(RecommendationFilters.none()))).thenReturn(empty);

        mockMvc.perform(get("/discovery/recommendations"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.recommendations").isEmpty())
            .andExpect(jsonPath("$.totalRecipesConsidered").value(0));
    }

    @Test
    void getRecommendations_passesBatchSizeQueryParamThrough() throws Exception
    {
        when(recommendationService.getRecommendations(eq(1), eq(15), isNull(), isNull(), eq(RecommendationFilters.none()))).thenReturn(response);

        mockMvc.perform(get("/discovery/recommendations").param("batchSize", "15"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.recommendations[0].recipeId").value(100));
    }

    @Test
    void getRecommendations_passesExcludeRecipeIdsQueryParamThrough() throws Exception
    {
        when(recommendationService.getRecommendations(eq(1), isNull(), eq(List.of(200, 201)), isNull(), eq(RecommendationFilters.none()))).thenReturn(response);

        mockMvc.perform(get("/discovery/recommendations")
            .param("excludeRecipeIds", "200", "201"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.recommendations[0].recipeId").value(100));
    }

    @Test
    void getRecommendations_passesSeedQueryParamThrough() throws Exception
    {
        when(recommendationService.getRecommendations(eq(1), isNull(), isNull(), eq(42), eq(RecommendationFilters.none()))).thenReturn(response);

        mockMvc.perform(get("/discovery/recommendations").param("seed", "42"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.recommendations[0].recipeId").value(100));
    }

    @Test
    void getRecommendations_returns400_whenBatchSizeIsNotAnInteger() throws Exception
    {
        mockMvc.perform(get("/discovery/recommendations").param("batchSize", "not-a-number"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void getRecommendations_passesFilterQueryParamsThrough() throws Exception
    {
        RecommendationFilters expected = new RecommendationFilters(30, 45, List.of("VEGETARIAN", "GLUTEN_FREE"));
        when(recommendationService.getRecommendations(eq(1), isNull(), isNull(), isNull(), eq(expected))).thenReturn(response);

        mockMvc.perform(get("/discovery/recommendations")
            .param("maxCookingTimeMins", "30")
            .param("maxTotalTimeMins", "45")
            .param("dietaryTags", "VEGETARIAN", "GLUTEN_FREE"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.recommendations[0].recipeId").value(100));
    }

    @Test
    void getRecommendations_returns400_whenMaxCookingTimeIsNotAnInteger() throws Exception
    {
        mockMvc.perform(get("/discovery/recommendations").param("maxCookingTimeMins", "soon"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void getRecommendations_returns400_whenServiceRejectsFilter() throws Exception
    {
        RecommendationFilters badTag = new RecommendationFilters(null, null, List.of("QUICK"));
        when(recommendationService.getRecommendations(eq(1), isNull(), isNull(), isNull(), eq(badTag)))
            .thenThrow(new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unknown dietary tag: QUICK."));

        mockMvc.perform(get("/discovery/recommendations").param("dietaryTags", "QUICK"))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.message").value("Unknown dietary tag: QUICK."));
    }
}