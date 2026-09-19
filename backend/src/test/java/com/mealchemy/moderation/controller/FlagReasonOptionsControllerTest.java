package com.mealchemy.moderation;

// dtos
import com.mealchemy.moderation.dto.FlagReasonOptionsResponse;

// controller
import com.mealchemy.moderation.controller.FlagReasonOptionsController;

// import service
import com.mealchemy.moderation.service.FlagReasonOptionsService;

import com.mealchemy.config.JwtUtil;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;


@WebMvcTest(FlagReasonOptionsController.class)
public class FlagReasonOptionsControllerTest {

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
    private FlagReasonOptionsService flagReasonOptionsService;

    @MockitoBean
    private JwtUtil jwtUtil;


    // ========== GET Testing (GET /flagreasons) ==========

    @Test
    void getAllFlagValueOptions_return200() throws Exception {
        // Arrange - mock response
        FlagReasonOptionsResponse flag1 = new FlagReasonOptionsResponse(
            "INAPPROPRIATE_LANGUAGE",
            "Inappropriate language"
        );

        FlagReasonOptionsResponse flag2 = new FlagReasonOptionsResponse(
            "SPAM_MISLEADING", 
            "Spam / misleading"
        );

        FlagReasonOptionsResponse flag3 = new FlagReasonOptionsResponse(
            "UNSAFE_INSTRUCTIONS", 
            "Unsafe or dangerous instructions"
        );

        when(flagReasonOptionsService.getAllFlagReasonOptions()).thenReturn(List.of(flag1, flag2, flag3));

        // Act and assert
        mockMvc.perform(get("/flagreasons/all").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$[0].value").value("INAPPROPRIATE_LANGUAGE"))
                .andExpect(jsonPath("$[0].label").value("Inappropriate language"))
                .andExpect(jsonPath("$[2].value").value("UNSAFE_INSTRUCTIONS"))
                .andExpect(jsonPath("$[2].label").value("Unsafe or dangerous instructions"));
    }
}