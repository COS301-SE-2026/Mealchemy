package com.mealchemy.preference;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.config.JwtUtil;
import com.mealchemy.preference.controller.PreferenceController;
import com.mealchemy.preference.dto.PreferenceRequest;
import com.mealchemy.preference.dto.PreferenceResponse;
import com.mealchemy.preference.service.PreferenceService;

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

import java.util.List;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(PreferenceController.class)
public class PreferenceControllerTest {

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
    private PreferenceService preferenceService;

    @MockitoBean
    private JwtUtil jwtUtil;

    // ========== Get Preferences Testing ==========

    @Test
    void getUserPreferences_withValidToken_returns200() throws Exception {
        // Arrange
        PreferenceResponse mockResponse = new PreferenceResponse(
            List.of("vegetarian"),
            List.of("peanuts"),
            List.of("olives"),
            List.of("mediterranean")
        );

        when(preferenceService.preferences(anyInt())).thenReturn(mockResponse);

        // Act and Assert
        // simulate user logged in has user_id 1
        mockMvc.perform(get("/user/preferences")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.dietary_restrictions[0]").value("vegetarian"))
            .andExpect(jsonPath("$.allergies[0]").value("peanuts"))
            .andExpect(jsonPath("$.disliked_ingredients[0]").value("olives"))
            .andExpect(jsonPath("$.flavour_profile[0]").value("mediterranean"));
    }

    @Test
    void getUserPreferences_whenUserNotFound_returns404() throws Exception {
        // Arrange
        when(preferenceService.preferences(anyInt()))
            .thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Preferences not found"));

        // Act and Assert
        mockMvc.perform(get("/user/preferences")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("Preferences not found"));
    }

    // ========== Update Preferences Testing ==========

    @Test
    void updateUserPreferences_withValidRequest_returns200() throws Exception {
        // Arrange
        PreferenceRequest request = new PreferenceRequest(
            List.of("vegan"),
            List.of("gluten"),
            List.of("anchovies"),
            List.of("japanese")
        );

        PreferenceResponse mockResponse = new PreferenceResponse(
            List.of("vegan"),
            List.of("gluten"),
            List.of("anchovies"),
            List.of("japanese")
        );

        when(preferenceService.updatePreferences(anyInt(), any(PreferenceRequest.class)))
            .thenReturn(mockResponse);

        // Act and Assert
        mockMvc.perform(put("/user/preferences")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.dietary_restrictions[0]").value("vegan"))
            .andExpect(jsonPath("$.allergies[0]").value("gluten"))
            .andExpect(jsonPath("$.disliked_ingredients[0]").value("anchovies"))
            .andExpect(jsonPath("$.flavour_profile[0]").value("japanese"));
    }

    @Test
    void updateUserPreferences_whenUserNotFound_returns404() throws Exception {
        // Arrange
        PreferenceRequest request = new PreferenceRequest(
            List.of("vegan"),
            List.of("gluten"),
            List.of("anchovies"),
            List.of("japanese")
        );

        when(preferenceService.updatePreferences(anyInt(), any(PreferenceRequest.class)))
            .thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Preferences not found"));

        // Act and Assert
        mockMvc.perform(put("/user/preferences")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("Preferences not found"));
    }
}