package com.mealchemy.moderation;

// dtos
import com.mealchemy.moderation.dto.FlaggedRecipeResponse;
import com.mealchemy.moderation.dto.FlagRequest;

// controller
import com.mealchemy.moderation.controller.FlagController;

// import service
import com.mealchemy.moderation.service.FlagService;

// enums
import com.mealchemy.shared.enums.FlagStatus;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.config.JwtUtil;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.http.MediaType;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.server.ResponseStatusException;

import java.time.OffsetDateTime;
import java.util.List;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;

import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;


@WebMvcTest(FlagController.class)
public class FlagControllerTest {

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
    private FlagService flagService;

    @MockitoBean
    private JwtUtil jwtUtil;


    // ========== POST Testing (POST /recipes/{recipeId}/flag) ==========

    @Test 
    void flagRecipeInGlobalVault_validRequest_returns200() throws Exception {
        // Arrange
        FlagRequest mockRequest = new FlagRequest("SPAM_MISLEADING");

        FlaggedRecipeResponse mockResponse = new FlaggedRecipeResponse(
            12, // flaggedId
            2, // recipeId
            "Penne Alla Vodka",
            "https://photoUr.com/penne,jpeg",
            4, // userId
            "SPAM_MISLEADING",
            "Spam / misleading",
            FlagStatus.PENDING,
            OffsetDateTime.parse("2026-09-17T23:00:00Z")
        );

        when(flagService.createFlag(eq(2), eq(mockRequest), anyInt())).thenReturn(mockResponse);

        // Act and assert
        mockMvc.perform(post("/recipes/{recipeId}/flag", 2).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$.flagged_id").value(12))
                .andExpect(jsonPath("$.recipe_id").value(2))
                .andExpect(jsonPath("$.recipe_title").value("Penne Alla Vodka"))
                .andExpect(jsonPath("$.recipe_photo_url").value("https://photoUr.com/penne,jpeg"))
                .andExpect(jsonPath("$.flagged_by_user_id").value(4))
                .andExpect(jsonPath("$.reason_value").value("SPAM_MISLEADING"))
                .andExpect(jsonPath("$.reason_label").value("Spam / misleading"))
                .andExpect(jsonPath("$.status").value("PENDING"));
    }

    @Test
    void flagRecipeInGlobalVault_invalidReason_return400() throws Exception {
        // Arrange 
        FlagRequest mockRequest = new FlagRequest("INVALID_REASON"); 

        when(flagService.createFlag(eq(2), eq(mockRequest), anyInt())).thenThrow(new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid reason value."));

        // Act and assert
        mockMvc.perform(post("/recipes/{recipeId}/flag", 2).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))        
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Invalid reason value."));
    }

    @Test 
    void flagRecipeInGlobalVault_recipeNotFound_returns404() throws Exception {
        // Arrange
        FlagRequest mockRequest = new FlagRequest("SPAM_MISLEADING");

        when(flagService.createFlag(eq(99), eq(mockRequest), anyInt())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        // Act and Assert
        mockMvc.perform(post("/recipes/{recipeId}/flag", 99).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Recipe not found."));
    }

    @Test 
    void flagRecipeInGlobalVault_duplicatePending_returns409() throws Exception {
        // Arrange
        FlagRequest mockRequest = new FlagRequest("SPAM_MISLEADING");

        when(flagService.createFlag(eq(2), eq(mockRequest), anyInt())).thenThrow(new ResponseStatusException(HttpStatus.CONFLICT, "You already have a pending flag on this recipe."));

        // Act and Assert
        mockMvc.perform(post("/recipes/{recipeId}/flag", 2).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.message").value("You already have a pending flag on this recipe."));
    }

}