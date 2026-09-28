// unit testing for meal plan controller

package com.mealchemy.mealprep.controller;

/* Import libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.server.ResponseStatusException;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.config.JwtUtil;

/* Import classes */
import com.mealchemy.mealprep.dto.MealPlanRequest;
import com.mealchemy.mealprep.dto.MealPlanResponse;
import com.mealchemy.mealprep.dto.MealPlanEntryRequest;
import com.mealchemy.mealprep.dto.MealPlanEntryResponse;
import com.mealchemy.mealprep.service.MealPlanService;
import com.mealchemy.mealprep.exception.InvalidMealSlotTimeException;
import com.mealchemy.shared.enums.MealSlot;
import com.mealchemy.shared.enums.MealPlanEntrySource;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.doNothing;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;


@WebMvcTest(MealPlanController.class)
public class MealPlanControllerTest {

    // setup
    @TestConfiguration
    static class TestSecurityConfig {
        @Bean
        public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
            http
                .csrf(AbstractHttpConfigurer::disable)
                .authorizeHttpRequests(auth -> auth.anyRequest().permitAll());
            return http.build();
        }
    }

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private MealPlanService mealPlanService;

    @MockitoBean
    private JwtUtil jwtUtil;

    private MealPlanRequest mealPlanRequest;
    private MealPlanEntryRequest mealPlanEntryRequest;
    private MealPlanResponse mealPlanResponse;
    private MealPlanEntryResponse mealPlanEntryResponse; 

    @BeforeEach
    void setUp() {

        mealPlanRequest = new MealPlanRequest(10);

        mealPlanEntryRequest = new MealPlanEntryRequest(
            50, 
            LocalDate.of(2026, 10, 1), 
            MealSlot.DINNER, 
            LocalTime.of(18, 0), 
            "Burrito Bowls", 
            "extra spicy"
        );

        mealPlanResponse = new MealPlanResponse(100, 10, 1);

        mealPlanEntryResponse = new MealPlanEntryResponse(
            20, 
            100, 
            50, 
            LocalDate.of(2026, 10, 1), 
            MealSlot.DINNER, 
            LocalTime.of(18, 0),
            "Burrito Bowls", 
            "extra spicy", 
            MealPlanEntrySource.MANUAL, 
            1
        );
    }

    // ========== POST Testing (POST /api/meal-plans) ==========

    @Test
    void getOrCreatePlan_validRequest_returns200() throws Exception {
        // Arrange
        when(mealPlanService.getOrCreatePlan(eq(10), anyInt())).thenReturn(mealPlanResponse);

        // Act and assert
        // Act and assert
        mockMvc.perform(post("/api/meal-plans").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mealPlanRequest)))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$.planId").value(100))
                .andExpect(jsonPath("$.vaultId").value(10))
                .andExpect(jsonPath("$.createdBy").value(1));
    }

    @Test
    void getOrCreatePlan_missingVaultId_returns400() throws Exception {
        // Arrange 
        // Bad request
       MealPlanRequest badRequest = new MealPlanRequest(null);

        // Act and Assert
        mockMvc.perform(post("/api/meal-plans").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(badRequest)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void getOrCreatePlan_vaultNotFound_return404() throws Exception {
        // Arrange
        when(mealPlanService.getOrCreatePlan(eq(10), anyInt())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        // Act and assert
        mockMvc.perform(post("/api/meal-plans").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                // fields in response object
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mealPlanRequest)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Vault not found."));
    }


    // ========== GET Testing (GET /api/meal-plans) ==========

    @Test
    void getEntries_validRequest_returns200() throws Exception {
        // Arrange
        when(mealPlanService.getOrCreatePlan(eq(10), anyInt())).thenReturn(mealPlanResponse);
        when(mealPlanService.getEntries(eq(100), anyInt(), eq(LocalDate.of(2026, 10, 1)), eq(LocalDate.of(2026, 10, 7)))).thenReturn(List.of(mealPlanEntryResponse));

        // Act and assert
        mockMvc.perform(get("/api/meal-plans").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .param("vaultId", "10")
                .param("startDate", "2026-10-01")
                .param("endDate", "2026-10-07"))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$[0].entryId").value(20))
                .andExpect(jsonPath("$[0].recipeId").value(50))
                .andExpect(jsonPath("$[0].mealSlot").value("DINNER"))
                .andExpect(jsonPath("$[0].source").value("MANUAL"));
    }

    @Test
    void getEntries_emptyResult_returns200() throws Exception {
        // Arrange
        when(mealPlanService.getOrCreatePlan(eq(10), anyInt())).thenReturn(mealPlanResponse);
        when(mealPlanService.getEntries(eq(100), anyInt(), eq(LocalDate.of(2026, 10, 1)), eq(LocalDate.of(2026, 10, 7)))).thenReturn(List.of());

        // Act and assert
        mockMvc.perform(get("/api/meal-plans").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .param("vaultId", "10")
                .param("startDate", "2026-10-01")
                .param("endDate", "2026-10-07"))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$").isEmpty());
    }

    @Test
    void getEntries_missingVaultId_returns400() throws Exception {
        // Act and Assert
        mockMvc.perform(get("/api/meal-plans").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .param("startDate", "2026-10-01")
                .param("startDate", "2026-10-01"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void getEntries_vaultNotFound_return404() throws Exception {
        // Arrange
        when(mealPlanService.getOrCreatePlan(eq(10), anyInt())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        // Act and assert
        mockMvc.perform(get("/api/meal-plans").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .param("vaultId", "10")
                .param("startDate", "2026-10-01")
                .param("endDate", "2026-10-07"))
                // fields in response object
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Vault not found."));
    }


    // ========== POST Testing (POST /api/meal-plans/{planId}/entries) ==========

    @Test
    void createManualEntry_validRequest_returns200() throws Exception {
        // Arrange
        when(mealPlanService.createManualEntry(eq(100), anyInt(), any(MealPlanEntryRequest.class))).thenReturn(mealPlanEntryResponse);
        
        // Act and assert
        mockMvc.perform(post("/api/meal-plans/{planId}/entries", 100).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mealPlanEntryRequest)))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$.entryId").value(20))
                .andExpect(jsonPath("$.title").value("Burrito Bowls"));
    }

    @Test
    void createManualEntry_missingRecipeId_returns400() throws Exception {
        // Arrange
        MealPlanEntryRequest badRequest = new MealPlanEntryRequest(
            null, 
            LocalDate.of(2026, 10, 1), 
            MealSlot.DINNER, 
            LocalTime.of(18, 0), 
            "Burrito Bowls", 
            "extra spicy"
        );
        
        // Act and Assert
        mockMvc.perform(post("/api/meal-plans/{planId}/entries", 100).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(badRequest)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void createManualEntry_vaultNotFound_return404() throws Exception {
        // Arrange
        when(mealPlanService.createManualEntry(eq(999), anyInt(), any(MealPlanEntryRequest.class))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Meal plan not found."));


        // Act and assert
        mockMvc.perform(post("/api/meal-plans/{planId}/entries", 999).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mealPlanEntryRequest)))
                // fields in response object
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Meal plan not found."));
    }

    @Test
    void createManualEntry_slotOccupied_returns409() throws Exception {
        // Arrange
        when(mealPlanService.createManualEntry(eq(100), anyInt(), any(MealPlanEntryRequest.class))).thenThrow(new ResponseStatusException(HttpStatus.CONFLICT, "An entry already exists for 2026-10-01 DINNER."));

        // Act and assert
        mockMvc.perform(post("/api/meal-plans/{planId}/entries", 100).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mealPlanEntryRequest)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.message").value("An entry already exists for 2026-10-01 DINNER."));
    }


    // ========== PUT Testing (PUT /api/meal-plans/{planId}/entries/{entryId}) ==========

    @Test
    void updateEntry_validRequest_returns200() throws Exception {
        // Arrange
        when(mealPlanService.updateEntry(eq(100), eq(20), anyInt(), any(MealPlanEntryRequest.class))).thenReturn(mealPlanEntryResponse);
        
        // Act and assert
        mockMvc.perform(put("/api/meal-plans/{planId}/entries/{entryId}", 100, 20).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mealPlanEntryRequest)))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$.entryId").value(20));
    }

    @Test
    void updateEntry_entryNotFound_return404() throws Exception {
        // Arrange
        when(mealPlanService.updateEntry(eq(100), eq(999), anyInt(), any(MealPlanEntryRequest.class))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Meal plan entry not found."));

        // Act and assert
        mockMvc.perform(put("/api/meal-plans/{planId}/entries/{entryId}", 100, 999).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mealPlanEntryRequest)))
                // fields in response object
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Meal plan entry not found."));
    }

    @Test
    void updateEntry_slotCollision_returns409() throws Exception {
        // Arrange
        when(mealPlanService.updateEntry(eq(100), eq(20), anyInt(), any(MealPlanEntryRequest.class))).thenThrow(new ResponseStatusException(HttpStatus.CONFLICT, "An entry already exists for 2026-10-01 DINNER."));

        // Act and assert
        mockMvc.perform(put("/api/meal-plans/{planId}/entries/{entryId}", 100, 20).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mealPlanEntryRequest)))
                // fields in response object
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.message").value("An entry already exists for 2026-10-01 DINNER."));
    }


    // ========== DELETE Testing (DELETE /api/meal-plans/{planId}/entries/{entryId}) ==========

    @Test
    void removeEntry_validRequest_returns204() throws Exception {
        // Arrange
        doNothing().when(mealPlanService).removeEntry(eq(100), eq(20), anyInt());

        // Act and assert
        mockMvc.perform(delete("/api/meal-plans/{planId}/entries/{entryId}", 100, 20)
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                // fields in response object
                .andExpect(status().isNoContent())
                .andExpect(content().string(""));
    }

    @Test
    void removeEntry_entryNotFound_returns404() throws Exception {
        // Arrange
        org.mockito.Mockito.doThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Meal plan entry not found.")).when(mealPlanService).removeEntry(eq(100), eq(999), anyInt());

        // Act and assert
        mockMvc.perform(delete("/api/meal-plans/{planId}/entries/{entryId}", 100, 999)
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                // fields in response object
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Meal plan entry not found."));
    }

    @Test
    void removeEntry_viewerNotEditor_returns403() throws Exception {
        // Arrange
        org.mockito.Mockito.doThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "Only a vault owner/editor can modify the meal plan.")).when(mealPlanService).removeEntry(eq(100), eq(20), anyInt());

        // Act and assert
        mockMvc.perform(delete("/api/meal-plans/{planId}/entries/{entryId}", 100, 20)
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                // fields in response object
                .andExpect(status().isForbidden());
    }

}