package com.mealchemy.profile;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.config.JwtUtil;
// controller 
import com.mealchemy.profile.controller.UserProfileController;
// dtos
import com.mealchemy.profile.dto.UserProfileResponse;
import com.mealchemy.profile.dto.UserProfileUpdateRequest;
// service
import com.mealchemy.profile.service.UserProfileService;

import com.mealchemy.shared.enums.PreferredUnit;

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
import java.time.OffsetDateTime;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(UserProfileController.class)
public class UserProfileControllerTest {

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
    private UserProfileService userProfileService;

    @MockitoBean
    private JwtUtil jwtUtil;

    // ========== Get UserProfile Testing ==========

    @Test
    void getUserProfile_withValidToken_returns200() throws Exception {
        // Arrange
        UserProfileResponse mockResponse = new UserProfileResponse(
            "test",
            "url",
            PreferredUnit.METRIC,
            List.of("Blender"),
            OffsetDateTime.parse("2026-08-19T23:00:00Z")
        );

        when(userProfileService.getUserProfile(anyInt())).thenReturn(mockResponse);

        // Act and Assert
        // simulate user logged in has user_id 1
        mockMvc.perform(get("/user/profile")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.display_name").value("test"))
                .andExpect(jsonPath("$.avatar_url").value("url"))
                .andExpect(jsonPath("$.preferred_unit").value("METRIC"))
                .andExpect(jsonPath("$.equipment[0]").value("Blender"));
    }

    @Test
    void getUserProfile_whenUserNotFound_returns404() throws Exception {
        // Arrange
        when(userProfileService.getUserProfile(anyInt()))
            .thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "User profile not found"));

        // Act and Assert
        mockMvc.perform(get("/user/profile")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("User profile not found"));
    }

    // ========== Update User Profile Testing ==========

    @Test
    void updateUserProfile_withValidRequest_returns200() throws Exception {
        // Arrange
        UserProfileUpdateRequest updateRequest = new UserProfileUpdateRequest(
            "test-2",
            "www",
            PreferredUnit.METRIC,
            List.of("Oven")
        );

        UserProfileResponse mockResponse = new UserProfileResponse(
            "test-2",
            "www",
            PreferredUnit.METRIC,
            List.of("Oven"),
            OffsetDateTime.parse("2026-08-19T23:00:00Z")
        );

        when(userProfileService.updateUserProfile(anyInt(), any(UserProfileUpdateRequest.class))).thenReturn(mockResponse);

        // Act and Assert
        mockMvc.perform(put("/user/profile")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updateRequest)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.display_name").value("test-2"))
            .andExpect(jsonPath("$.avatar_url").value("www"))
            .andExpect(jsonPath("$.preferred_unit").value("METRIC"))
            .andExpect(jsonPath("$.equipment[0]").value("Oven"));
    }

    @Test
    void updateUserProfile_whenUserNotFound_returns404() throws Exception {
        // Arrange
        UserProfileUpdateRequest updateRequest = new UserProfileUpdateRequest(
            "test",
            "www",
            PreferredUnit.IMPERIAL,
            List.of("Oven")
        );

        when(userProfileService.updateUserProfile(anyInt(), any(UserProfileUpdateRequest.class))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "User profile not found"));

        // Act and Assert
        mockMvc.perform(put("/user/profile")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updateRequest)))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("User profile not found"));
    }
}