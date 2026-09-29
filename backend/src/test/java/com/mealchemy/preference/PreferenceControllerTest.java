package com.mealchemy.preference;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.config.JwtUtil;
import com.mealchemy.preference.controller.PreferenceController;
import com.mealchemy.preference.dto.PreferenceRequest;
import com.mealchemy.preference.dto.PreferenceResponse;
import com.mealchemy.preference.dto.UserPreferenceWeightsRequest;
import com.mealchemy.preference.dto.UserPreferenceWeightsResponse;
import com.mealchemy.preference.service.PreferenceService;
import com.mealchemy.preference.service.PreferenceWeightsService;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
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

import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
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
    private PreferenceWeightsService preferenceWeightsService;

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
            List.of("mediterranean"),
            List.of("low_carb")
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
            .andExpect(jsonPath("$.flavour_profile[0]").value("mediterranean"))
            .andExpect(jsonPath("$.nutritional_goals[0]").value("low_carb"));
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
            List.of("japanese"),
            List.of("low_carb")
        );

        PreferenceResponse mockResponse = new PreferenceResponse(
            List.of("vegan"),
            List.of("gluten"),
            List.of("anchovies"),
            List.of("japanese"),
            List.of("low_carb")
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
            .andExpect(jsonPath("$.flavour_profile[0]").value("japanese"))
            .andExpect(jsonPath("$.nutritional_goals[0]").value("low_carb"));
    }

    @Test
    void updateUserPreferences_whenUserNotFound_returns404() throws Exception {
        // Arrange
        PreferenceRequest request = new PreferenceRequest(
            List.of("vegan"),
            List.of("gluten"),
            List.of("anchovies"),
            List.of("japanese"),
            List.of("low_carb")
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

    // ========== Get Weights Testing ==========

    @Test
    void getUserPreferenceWeights_withValidToken_returns200() throws Exception {
        // Arrange
        UserPreferenceWeightsResponse mockResponse = new UserPreferenceWeightsResponse(
            new BigDecimal("0.4000"),
            new BigDecimal("0.2500"),
            new BigDecimal("0.1000"),
            new BigDecimal("0.1500"),
            new BigDecimal("0.1000")
        );

        when(preferenceWeightsService.getWeights(anyInt())).thenReturn(mockResponse);

        // Act and Assert
        mockMvc.perform(get("/user/preferences/weights")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.pantry_match").value(0.4))
            .andExpect(jsonPath("$.cuisine").value(0.25))
            .andExpect(jsonPath("$.nutrition").value(0.1))
            .andExpect(jsonPath("$.freshness").value(0.15))
            .andExpect(jsonPath("$.novelty").value(0.1));
    }

    @Test
    void getUserPreferenceWeights_passesUserIdFromTokenToService() throws Exception {
        // Arrange
        when(preferenceWeightsService.getWeights(anyInt())).thenReturn(new UserPreferenceWeightsResponse(
            new BigDecimal("0.4000"), new BigDecimal("0.2500"), new BigDecimal("0.1000"),
            new BigDecimal("0.1500"), new BigDecimal("0.1000")
        ));

        // Act
        mockMvc.perform(get("/user/preferences/weights")
                .with(authentication(new UsernamePasswordAuthenticationToken("42", null, List.of()))))
            .andExpect(status().isOk());

        // Assert
        verify(preferenceWeightsService).getWeights(42);
    }

    @Test
    void getUserPreferenceWeights_whenServiceFails_returns500() throws Exception {
        // Arrange
        when(preferenceWeightsService.getWeights(anyInt()))
            .thenThrow(new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Could not create default weights"));

        // Act and Assert
        mockMvc.perform(get("/user/preferences/weights")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
            .andExpect(status().isInternalServerError())
            .andExpect(jsonPath("$.message").value("Could not create default weights"));
    }

    // ========== Update Weights Testing ==========

    @Test
    void updateUserPreferenceWeights_withValidRequest_returns200() throws Exception {
        // Arrange
        UserPreferenceWeightsRequest request = new UserPreferenceWeightsRequest(
            new BigDecimal("0.50"),
            new BigDecimal("0.20"),
            new BigDecimal("0.10"),
            new BigDecimal("0.10"),
            new BigDecimal("0.10")
        );

        UserPreferenceWeightsResponse mockResponse = new UserPreferenceWeightsResponse(
            new BigDecimal("0.5000"),
            new BigDecimal("0.2000"),
            new BigDecimal("0.1000"),
            new BigDecimal("0.1000"),
            new BigDecimal("0.1000")
        );

        when(preferenceWeightsService.updateWeights(anyInt(), any(UserPreferenceWeightsRequest.class)))
            .thenReturn(mockResponse);

        // Act and Assert
        mockMvc.perform(put("/user/preferences/weights")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.pantry_match").value(0.5))
            .andExpect(jsonPath("$.cuisine").value(0.2))
            .andExpect(jsonPath("$.nutrition").value(0.1))
            .andExpect(jsonPath("$.freshness").value(0.1))
            .andExpect(jsonPath("$.novelty").value(0.1));
    }

    @Test
    void updateUserPreferenceWeights_mapsSnakeCaseBodyAndUserIdToService() throws Exception {
        // Arrange 
        String json = """
            {"pantry_match": 0.40, "cuisine": 0.25, "nutrition": 0.10, "freshness": 0.15, "novelty": 0.10}
            """;

        when(preferenceWeightsService.updateWeights(anyInt(), any(UserPreferenceWeightsRequest.class)))
            .thenReturn(new UserPreferenceWeightsResponse(
                new BigDecimal("0.4000"), new BigDecimal("0.2500"), new BigDecimal("0.1000"),
                new BigDecimal("0.1500"), new BigDecimal("0.1000")
            ));

        // Act
        mockMvc.perform(put("/user/preferences/weights")
                .with(authentication(new UsernamePasswordAuthenticationToken("42", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(json))
            .andExpect(status().isOk());

        // Assert
        ArgumentCaptor<UserPreferenceWeightsRequest> captor = ArgumentCaptor.forClass(UserPreferenceWeightsRequest.class);
        verify(preferenceWeightsService).updateWeights(eq(42), captor.capture());

        UserPreferenceWeightsRequest received = captor.getValue();
        assertEquals(0, new BigDecimal("0.40").compareTo(received.pantryMatch()));
        assertEquals(0, new BigDecimal("0.25").compareTo(received.cuisine()));
        assertEquals(0, new BigDecimal("0.10").compareTo(received.nutrition()));
        assertEquals(0, new BigDecimal("0.15").compareTo(received.freshness()));
        assertEquals(0, new BigDecimal("0.10").compareTo(received.novelty()));
    }

    @Test
    void updateUserPreferenceWeights_whenServiceRejectsValues_returns400() throws Exception {
        // Arrange
        UserPreferenceWeightsRequest request = new UserPreferenceWeightsRequest(
            new BigDecimal("0.90"),
            new BigDecimal("0.20"),
            new BigDecimal("0.10"),
            new BigDecimal("0.10"),
            new BigDecimal("0.10")
        );

        when(preferenceWeightsService.updateWeights(anyInt(), any(UserPreferenceWeightsRequest.class)))
            .thenThrow(new ResponseStatusException(HttpStatus.BAD_REQUEST, "Weights must sum to 1.0 (within 0.001)"));

        // Act and Assert
        mockMvc.perform(put("/user/preferences/weights")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.message").value("Weights must sum to 1.0 (within 0.001)"));
    }

    @Test
    void updateUserPreferenceWeights_withNonNumericValue_returns400() throws Exception {
        // Arrange
        String json = """
            {"pantry_match": "abc", "cuisine": 0.25, "nutrition": 0.10, "freshness": 0.15, "novelty": 0.10}
            """;

        // Act and Assert
        mockMvc.perform(put("/user/preferences/weights")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(json))
            .andExpect(status().isBadRequest());

        verifyNoInteractions(preferenceWeightsService);
    }

    @Test
    void updateUserPreferenceWeights_whenServiceFails_returns500() throws Exception {
        // Arrange
        UserPreferenceWeightsRequest request = new UserPreferenceWeightsRequest(
            new BigDecimal("0.50"),
            new BigDecimal("0.20"),
            new BigDecimal("0.10"),
            new BigDecimal("0.10"),
            new BigDecimal("0.10")
        );

        when(preferenceWeightsService.updateWeights(anyInt(), any(UserPreferenceWeightsRequest.class)))
            .thenThrow(new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Could not save weights, please retry"));

        // Act and Assert
        mockMvc.perform(put("/user/preferences/weights")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isInternalServerError())
            .andExpect(jsonPath("$.message").value("Could not save weights, please retry"));
    }
}