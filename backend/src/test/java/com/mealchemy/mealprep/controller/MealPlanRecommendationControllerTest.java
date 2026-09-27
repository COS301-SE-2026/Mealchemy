package com.mealchemy.mealprep.controller;

/* Import libraries */
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import com.mealchemy.config.JwtUtil;
import com.mealchemy.config.WithMockJwtUser;

import static org.hamcrest.Matchers.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/* Import classes */
import com.mealchemy.mealprep.service.MealPlanRecommendationService;
import com.mealchemy.mealprep.dto.*;
import com.mealchemy.engine.dto.EnrichedRecommendationResponse;
import com.mealchemy.engine.dto.EnrichedRecommendationItem;
import com.mealchemy.engine.dto.SignalScoresResponse;
import com.mealchemy.recipe.dto.RecipeResponse;
import com.mealchemy.shared.enums.MealSlot;
import com.mealchemy.shared.enums.MealPlanEntrySource;

@ExtendWith(SpringExtension.class)
@WebMvcTest(MealPlanRecommendationController.class)
@WithMockJwtUser(userId = "1")
public class MealPlanRecommendationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private JwtUtil jwtUtil;

    @MockitoBean
    private MealPlanRecommendationService mealPlanRecommendationService;

    private static final Integer PLAN_ID = 10;
    private static final Integer RECIPE_ID = 100;

    private EnrichedRecommendationItem pick() {
        RecipeResponse recipe = new RecipeResponse(RECIPE_ID, 1, "Test Recipe", "desc", "ITALIAN",
            10, 10, 2, null, null, null, true, null, null, null);
        return new EnrichedRecommendationItem(RECIPE_ID, "ITALIAN", new BigDecimal("0.8"),
            new SignalScoresResponse(0.5, 0.5, 0.5, 0.5, 0.5), 0, List.of(), List.of(), recipe);
    }

    // ========== POST /days/{date}/recommendations ==========

    @Test
    void getDayRecommendations_returns200_withRecommendations() throws Exception {
        DayRecommendationResponse response = new DayRecommendationResponse(LocalDate.of(2026, 10, 1), MealSlot.DINNER, List.of(pick()));
        when(mealPlanRecommendationService.getDayRecommendations(eq(1), eq(PLAN_ID), eq(LocalDate.of(2026, 10, 1)), any(DayRecommendationRequest.class)))
            .thenReturn(response);

        mockMvc.perform(post("/api/meal-plans/{planId}/days/{date}/recommendations", PLAN_ID, "2026-10-01")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"mealSlot\":\"DINNER\",\"count\":3}"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.mealSlot").value("DINNER"))
            .andExpect(jsonPath("$.recommendations[0].recipeId").value(RECIPE_ID));
    }

    @Test
    void getDayRecommendations_returns403_whenVaultIsShared() throws Exception {
        when(mealPlanRecommendationService.getDayRecommendations(eq(1), eq(PLAN_ID), any(), any()))
            .thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "Recommendation-based meal planning is only available for private vaults."));

        mockMvc.perform(post("/api/meal-plans/{planId}/days/{date}/recommendations", PLAN_ID, "2026-10-01")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"mealSlot\":\"DINNER\",\"count\":3}"))
            .andExpect(status().isForbidden());
    }

    @Test
    void getDayRecommendations_returns400_whenMissingRequiredField() throws Exception {
        mockMvc.perform(post("/api/meal-plans/{planId}/days/{date}/recommendations", PLAN_ID, "2026-10-01")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"count\":3}"))
            .andExpect(status().isBadRequest());
    }

    // ========== POST /recommendations/generate ==========

    @Test
    void generate_returns200_withGeneratedEntries() throws Exception {
        MealPlanEntryResponse entry = new MealPlanEntryResponse(55, PLAN_ID, RECIPE_ID, LocalDate.of(2026, 10, 1),
            MealSlot.DINNER, LocalTime.of(18, 0), null, null, MealPlanEntrySource.RECOMMENDED, 1);
        GenerateRecommendationsResponse response = new GenerateRecommendationsResponse(List.of(entry), List.of());
        when(mealPlanRecommendationService.generate(eq(1), eq(PLAN_ID), any(GenerateRecommendationsRequest.class)))
            .thenReturn(response);

        String body = "{\"startDate\":\"2026-10-01\",\"endDate\":\"2026-10-01\",\"mealSlots\":[\"DINNER\"],"
            + "\"slotTimes\":{\"DINNER\":\"18:00:00\"},\"overwriteRecommended\":false}";

        mockMvc.perform(post("/api/meal-plans/{planId}/recommendations/generate", PLAN_ID)
                .contentType(MediaType.APPLICATION_JSON)
                .content(body))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.generatedEntries", hasSize(1)))
            .andExpect(jsonPath("$.skippedDates").isEmpty());
    }

    @Test
    void generate_returns400_whenStartDateAfterEndDate() throws Exception {
        when(mealPlanRecommendationService.generate(eq(1), eq(PLAN_ID), any(GenerateRecommendationsRequest.class)))
            .thenThrow(new ResponseStatusException(HttpStatus.BAD_REQUEST, "startDate must not be after endDate."));

        String body = "{\"startDate\":\"2026-10-05\",\"endDate\":\"2026-10-01\",\"mealSlots\":[\"DINNER\"],"
            + "\"slotTimes\":{\"DINNER\":\"18:00:00\"},\"overwriteRecommended\":false}";

        mockMvc.perform(post("/api/meal-plans/{planId}/recommendations/generate", PLAN_ID)
                .contentType(MediaType.APPLICATION_JSON)
                .content(body))
            .andExpect(status().isBadRequest());
    }

    @Test
    void generate_returns400_whenSlotTimesMissing() throws Exception {
        String body = "{\"startDate\":\"2026-10-01\",\"endDate\":\"2026-10-01\",\"mealSlots\":[\"DINNER\"],"
            + "\"overwriteRecommended\":false}";

        mockMvc.perform(post("/api/meal-plans/{planId}/recommendations/generate", PLAN_ID)
                .contentType(MediaType.APPLICATION_JSON)
                .content(body))
            .andExpect(status().isBadRequest());
    }

    // ========== POST /entries/from-recommendation ==========

    @Test
    void addEntryFromRecommendation_returns200_withCreatedEntry() throws Exception {
        MealPlanEntryResponse entry = new MealPlanEntryResponse(1, PLAN_ID, RECIPE_ID, LocalDate.of(2026, 10, 1),
            MealSlot.DINNER, LocalTime.of(18, 0), null, null, MealPlanEntrySource.RECOMMENDED, 1);
        when(mealPlanRecommendationService.addEntryFromRecommendation(eq(PLAN_ID), eq(1), any(MealPlanEntryFromRecommendationRequest.class)))
            .thenReturn(entry);

        String body = "{\"recipeId\":100,\"entryDate\":\"2026-10-01\",\"mealSlot\":\"DINNER\",\"mealTime\":\"18:00:00\","
            + "\"cuisineType\":\"ITALIAN\",\"scoreBreakdown\":{\"pantryMatch\":0.5,\"cuisine\":0.5,\"nutrition\":0.5,\"freshness\":0.5,\"novelty\":0.5}}";

        mockMvc.perform(post("/api/meal-plans/{planId}/entries/from-recommendation", PLAN_ID)
                .contentType(MediaType.APPLICATION_JSON)
                .content(body))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.entryId").value(1))
            .andExpect(jsonPath("$.source").value("RECOMMENDED"));
    }

    @Test
    void addEntryFromRecommendation_returns409_whenSlotOccupied() throws Exception {
        when(mealPlanRecommendationService.addEntryFromRecommendation(eq(PLAN_ID), eq(1), any(MealPlanEntryFromRecommendationRequest.class)))
            .thenThrow(new ResponseStatusException(HttpStatus.CONFLICT, "An entry already exists for 2026-10-01 DINNER."));

        String body = "{\"recipeId\":100,\"entryDate\":\"2026-10-01\",\"mealSlot\":\"DINNER\",\"mealTime\":\"18:00:00\","
            + "\"cuisineType\":\"ITALIAN\",\"scoreBreakdown\":{\"pantryMatch\":0.5,\"cuisine\":0.5,\"nutrition\":0.5,\"freshness\":0.5,\"novelty\":0.5}}";

        mockMvc.perform(post("/api/meal-plans/{planId}/entries/from-recommendation", PLAN_ID)
                .contentType(MediaType.APPLICATION_JSON)
                .content(body))
            .andExpect(status().isConflict());
    }

    @Test
    void addEntryFromRecommendation_returns400_whenScoreBreakdownMissing() throws Exception {
        String body = "{\"recipeId\":100,\"entryDate\":\"2026-10-01\",\"mealSlot\":\"DINNER\",\"mealTime\":\"18:00:00\","
            + "\"cuisineType\":\"ITALIAN\"}";

        mockMvc.perform(post("/api/meal-plans/{planId}/entries/from-recommendation", PLAN_ID)
                .contentType(MediaType.APPLICATION_JSON)
                .content(body))
            .andExpect(status().isBadRequest());
    }
}