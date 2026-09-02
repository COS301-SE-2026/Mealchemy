package com.mealchemy.auth;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.auth.controller.AuthController;
import com.mealchemy.auth.dto.AuthResponse;
import com.mealchemy.auth.dto.LoginRequest;
import com.mealchemy.auth.dto.RegisterRequest;
import com.mealchemy.auth.service.AuthService;
import com.mealchemy.config.JwtAuthFilter;
import com.mealchemy.config.JwtUtil;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.server.ResponseStatusException;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(AuthController.class)  //load web layer
@Import({JwtAuthFilter.class, JwtUtil.class})  //SecurityConfig
public class AuthControllerTest {

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
    private MockMvc mockMvc;  //fake http client

    @Autowired
    private ObjectMapper objectMapper;  //convert object to json

    @MockitoBean
    private AuthService authService;  //fake service controller talks to

    @MockitoBean
    private JwtUtil jwtUtil;  

    // ========== Registration Testing ==========

    // Happy path
    @Test
    void register_withValidRequest_returns200() throws Exception {
        // Arrange
        RegisterRequest request = new RegisterRequest(
            "test@test.com",
            "password123!",
            "Test User"
        );

        AuthResponse mockResponse = new AuthResponse(1, "mock.jwt.token", true);

        when(authService.register(any(RegisterRequest.class))).thenReturn(mockResponse);

        // Act and Assert
        mockMvc.perform(post("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())             // 200  
            .andExpect(jsonPath("$.user_id").value(1))
            .andExpect(jsonPath("$.token").value("mock.jwt.token"))
            .andExpect(jsonPath("$.onboarding_required").value(true));
    }

    // Negative path
    @Test
    void register_withMissingEmail_returns400() throws Exception {
        // Arrange - email missing
        RegisterRequest request = new RegisterRequest(
            "",
            "password123!",
            "Test User"
        );

        // Act and Assert 
        mockMvc.perform(post("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isBadRequest());  // 400
    }

    @Test
    void register_withMissingPassword_returns400() throws Exception {
        // Arrange - password missing
        RegisterRequest request = new RegisterRequest(
            "test@test.com",
            "",
            "Test User"
        );

        mockMvc.perform(post("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isBadRequest());  // 400
    }

    @Test
    void register_whenEmailAlreadyExists_returns409() throws Exception {
        // Arrange - email already exists
        RegisterRequest request = new RegisterRequest(
            "test@test.com",
            "password123!",
            "Test User"
        );

        when(authService.register(any(RegisterRequest.class)))
            .thenThrow(new ResponseStatusException(HttpStatus.CONFLICT, "Email already registered"));

        // Act and Assert
        mockMvc.perform(post("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isConflict())  // 409
            .andExpect(jsonPath("$.message").value("Email already registered"));
    }

    // ========== Login Testing ==========

    // Happy Path
    @Test
    void login_withValidCredentials_returns200() throws Exception {
        // Arrange
        LoginRequest request = new LoginRequest(
            "test@test.com",
            "password123!"
        );

        AuthResponse mockResponse = new AuthResponse(1, "mock.jwt.token", false);

        when(authService.login(any(LoginRequest.class))).thenReturn(mockResponse);

        // Act and Assert
        mockMvc.perform(post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())                    // 200
            .andExpect(jsonPath("$.user_id").value(1))
            .andExpect(jsonPath("$.token").value("mock.jwt.token"))
            .andExpect(jsonPath("$.onboarding_required").value(false));
    }

    @Test
    void login_withInvalidCredentials_returns401() throws Exception {
        // Arrange - wrong password (service throws error)
        LoginRequest request = new LoginRequest(
            "test@test.com",
            "wrongpassword"
        );

        when(authService.login(any(LoginRequest.class)))
            .thenThrow(new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials"));

        // Act and Assert
        mockMvc.perform(post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isUnauthorized())  // 401
            .andExpect(jsonPath("$.message").value("Invalid credentials"));
    }

    @Test
    void login_withMissingEmail_returns400() throws Exception {
        LoginRequest request = new LoginRequest(
            "",
            "password123!"
        );

        mockMvc.perform(post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isBadRequest());  // 400
    }
}